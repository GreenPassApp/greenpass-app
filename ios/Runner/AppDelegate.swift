import UIKit
import Flutter
import MLKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let mlkitVisionChannel = FlutterMethodChannel(name: "eu.greenpassapp.greenpass/mlkit_vision", binaryMessenger: controller.binaryMessenger)
    
    mlkitVisionChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard call.method == "scanQrCodeInImage" else {
            result(FlutterMethodNotImplemented)
            return
        }
        if let args = call.arguments as? Dictionary<String, Any>,
           let filepath = args["filename"] as? String {
            let image = VisionImage(image: UIImage(contentsOfFile: filepath)!)
            BarcodeScanner.barcodeScanner(options: BarcodeScannerOptions(formats: BarcodeFormat.qrCode)).process(image) { features, error in
                guard error == nil, features != nil else {
                    result(FlutterError.init(code: "DETECTION_ERROR", message: "There was an error detecting the QR code.", details: nil))
                    return
                }
                let res = features!.map{ $0.rawValue! }
                result(res)
            }
        } else {
            result(FlutterError.init(code: "DETECTION_ERROR", message: "There was an error detecting the QR code.", details: nil))
        }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
