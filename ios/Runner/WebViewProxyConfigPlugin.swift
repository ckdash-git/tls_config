//
//  WebViewProxyConfigPlugin.swift
//  Runner
//
//  Created by CIPL User01 on 10/09/25.
//


public class WebViewProxyConfigPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "webview_proxy_config", binaryMessenger: registrar.messenger())
        let instance = WebViewProxyConfigPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setWebivewProxyConfig":
            guard let args = call.arguments as? [String: String],
                  let proxyHost = args["proxy_host"],
                  let proxyPort = args["proxy_port"],
                  let endpoint = args["endpoint"] as? String,
                  let userIdHash = args["userIdHash"]  as? String,
                  let tenantIdHash = args["tenantIdHash"] as? String,
                  let sessionId = args["sessionId"]  as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            
            let completion: (Error?) -> Void = { error in
                if let error = error {
                    result(FlutterError(code: "PROXY_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    result(nil)
                }
            }
            
            WebViewProxyConfig.shared.setWebivewProxyConfig(proxyHost: proxyHost, proxyPort: proxyPort,endpoint: endpoint, userIdHash: userIdHash, tenantIdHash: tenantIdHash, sessionID: sessionId)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
