import UIKit
import Flutter
import PassKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKAddPassesViewControllerDelegate {
  override func application(
    _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "eu.greenpassapp.wallet", binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          // Note: this method is invoked on the UI thread.
          guard call.method == "addPassIntoWallet" else {
            result(FlutterMethodNotImplemented)
            return
          }
            if let args = call.arguments as? Dictionary<String, String>,
               let param = args["uri"] {
                self?.addPass(result: result, uri: param)

             } else {
               result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
             }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func addPass(result: FlutterResult, uri: String) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: uri)!)
            result(true)

        }else {
            result(false)
        }
    }
}
