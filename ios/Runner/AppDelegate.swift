import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
          
          // Register certificate manager plugin
      CertificateManagerPlugin.register(with: registrar(forPlugin: "CertificateManagerPlugin")!)
      WebViewProxyConfigPlugin.register(with: registrar(forPlugin: "WebViewProxyConfigPlugin")!)
          
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
