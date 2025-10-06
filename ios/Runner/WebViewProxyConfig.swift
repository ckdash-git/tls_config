//
//  WebViewProxyConfig.swift
//  Runner
//
//  Created by CIPL User01 on 10/09/25.
//

import UIKit
import Network
import WebKit

class WebViewProxyConfig {
    static let shared = WebViewProxyConfig()
    
    public func setWebivewProxyConfig(proxyHost: String, proxyPort: String,endpoint: String,userIdHash: String,tenantIdHash: String,sessionID: String){
        if #available(iOS 17.0, *) {
            let host = NWEndpoint.Host(proxyHost)
            
            // Convert proxyPort String to UInt16, then to NWEndpoint.Port
            guard let portValue = UInt16(proxyPort) else {
                print("Invalid port number")
                return
            }
            let port = NWEndpoint.Port(integerLiteral: portValue)
            
            // Create proxy configuration
            let proxyConfig = ProxyConfiguration(httpCONNECTProxy: NWEndpoint.hostPort(host: host, port: port))
        
            WKWebsiteDataStore.default().proxyConfigurations = [proxyConfig]
            
            print("WKWebView proxy configured successfully for \(proxyHost):\(proxyPort)")
        } else {
            // Handle older iOS versions
            print("WKWebView proxy configuration is not supported on iOS < 17.0")
        }
    }
}
