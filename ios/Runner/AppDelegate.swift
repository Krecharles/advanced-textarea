import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "clipboard/image",
                                                  binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          // Note: this method is invoked on the UI thread.
            guard call.method == "getClipboardImage" else {
              result(FlutterMethodNotImplemented)
              return
            }
            self.getClipboardImage(result: result)
        })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    
    // https://flutter.dev/docs/development/platform-integration/platform-channels#step-4-add-an-ios-platform-specific-implementation
    // https://www.raywenderlich.com/2882495-your-own-image-picker-with-flutter-channels#toc-anchor-008
    private func getClipboardImage(result: FlutterResult) {
      
        let image = UIPasteboard.general.image;
        
        if (image == nil) {
            print("no image in clipboard")
            return
        }
        
        let data = image!.jpegData(compressionQuality: 0.9)
        result(data)
        
    }
    
}
