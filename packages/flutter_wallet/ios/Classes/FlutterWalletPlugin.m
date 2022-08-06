#import "FlutterWalletPlugin.h"
#import <PassKit/PassKit.h>

@implementation FlutterWalletPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.vico-aguado.flutter/wallet"
            binaryMessenger:[registrar messenger]];
  FlutterWalletPlugin* instance = [[FlutterWalletPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"addWalletPass" isEqualToString:call.method]) {
      
      if (call.arguments != nil) {
          if ([call.arguments[@"pkpass"] isEqual:[NSNull null]]) {
              result([FlutterError errorWithCode:@"WITHOUT_PARAMETERS" message:@"Don't have 'pkpass' parameter" details:@"You need add 'pkpass' parameter"]);
          } else {
              //NSString *className = NSStringFromClass([call.arguments[@"pkpass"] class]);
              //NSLog(@"call.arguments['pkpass'] is a: %@", className);
              
              if ([call.arguments[@"pkpass"] isKindOfClass:[FlutterStandardTypedData class]]) {
                FlutterStandardTypedData *pkpassdata = call.arguments[@"pkpass"];
                  
                NSError* errorPass = nil;
                PKPass *newPass = [[PKPass alloc] initWithData:pkpassdata.data
                                                         error:&errorPass];
                
                if (errorPass!=nil) {
                    result([FlutterError errorWithCode:@"PKPASS_ERROR" message:[errorPass localizedDescription] details:nil]);
                }else{
                    UIViewController *rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
                    
                    if (rootController != nil) {
                        PKAddPassesViewController *addController = [[PKAddPassesViewController alloc] initWithPass:newPass];
                        [rootController presentViewController:addController animated:YES completion:nil];
                    } else {
                        result([FlutterError errorWithCode:@"ROOTCONTROLLER_INVALID" message:@"rootViewController of the app is invalid" details:nil]);
                    }
                    result([NSNumber numberWithBool:YES]);
                }
              } else {
                result([FlutterError errorWithCode:@"PARAMETERS_INVALID" message:@"Your 'pkpass' parameter is invalid (Not is FlutterStandardTypedData)" details:nil]);
              }
              
              
              /*
              if ([call.arguments[@"pkpass"] isKindOfClass:[NSArray class]]) {
                  NSArray *pkpassArray = call.arguments[@"pkpass"];
                  if ([pkpassArray count] > 0) {
                      NSMutableData *data = [[NSMutableData alloc] initWithCapacity: [pkpassArray count]];
                      for( NSNumber *number in pkpassArray) {
                          char byte = [number charValue];
                          [data appendBytes: &byte length: 1];
                      }
                      
                      NSError* errorPass = nil;
                      PKPass *newPass = [[PKPass alloc] initWithData:data
                                                               error:&errorPass];
                      
                      if (errorPass!=nil) {
                          result([FlutterError errorWithCode:@"PKPASS_ERROR" message:[errorPass localizedDescription] details:nil]);
                      }else{
                          UIViewController *rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
                          
                          if (rootController != nil) {
                              PKAddPassesViewController *addController = [[PKAddPassesViewController alloc] initWithPass:newPass];
                              [rootController presentViewController:addController animated:YES completion:nil];
                          } else {
                              result([FlutterError errorWithCode:@"ROOTCONTROLLER_INVALID" message:@"rootViewController of the app is invalid" details:nil]);
                          }
                          result([NSNumber numberWithBool:YES]);
                      }
                  } else {
                      result([FlutterError errorWithCode:@"PARAMETERS_INVALID" message:@"Your 'pkpass' parameter is invalid" details:nil]);
                  }
              } else {
                  result([FlutterError errorWithCode:@"PARAMETERS_INVALID" message:@"Your 'pkpass' parameter is invalid" details:nil]);
              }*/
          }
      }else{
          result([FlutterError errorWithCode:@"WITHOUT_PARAMETERS" message:@"Don't have 'pkpass' parameter" details:@"You need add 'pkpass' parameter"]);
      }
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
