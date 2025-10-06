//
//  CertificateManagerPlugin.swift
//  Runner
//
//  Created by CIPL User01 on 11/09/25.
//

class CertificateManagerPlugin: NSObject, FlutterPlugin {
    private var customCA: SecCertificate?
    
   public static func register(with registrar: FlutterPluginRegistrar) {
            let channel = FlutterMethodChannel(name: "certificate_manager", binaryMessenger: registrar.messenger())
            let instance = CertificateManagerPlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setCustomCA":
            if let args = call.arguments as? [String: Any],
               let caCert = args["caCert"] as? String {
                setCustomCA(caCertPem: caCert, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "CA certificate is required", details: nil))
            }
        case "setupCertificateValidation":
            setupCertificateValidation(result: result)
        case "validateCertificate":
            if let args = call.arguments as? [String: Any],
               let host = args["host"] as? String,
               let certificate = args["certificate"] as? String {
                validateCertificate(host: host, certificatePem: certificate, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Host and certificate are required", details: nil))
            }
        case "getCertificateInfo":
            getCertificateInfo(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setCustomCA(caCertPem: String, result: @escaping FlutterResult) {
        // Remove PEM headers/footers and convert to base64 data
        let pemContent = caCertPem
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = Data(base64Encoded: pemContent) else {
            result(FlutterError(code: "CA_LOAD_ERROR", message: "Failed to decode base64 certificate data", details: nil))
            return
        }
        
        let cfData = data as CFData
        guard let certificate = SecCertificateCreateWithData(nil, cfData) else {
            result(FlutterError(code: "CA_LOAD_ERROR", message: "Failed to create certificate from data", details: nil))
            return
        }
        
        customCA = certificate
        result(true)
    }
    
    private func setupCertificateValidation(result: @escaping FlutterResult) {
        // iOS certificate validation setup
        URLSessionConfiguration.default.urlCredentialStorage = URLCredentialStorage.shared
        result(true)
    }
    
    private func validateCertificate(host: String, certificatePem: String, result: @escaping FlutterResult) {
        guard let customCA = customCA else {
            result(false)
            return
        }
        
        // Remove PEM headers/footers and convert to base64 data
        let pemContent = certificatePem
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = Data(base64Encoded: pemContent),
              let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
            result(FlutterError(code: "VALIDATION_ERROR", message: "Invalid certificate format", details: nil))
            return
        }
        
        // Create trust object
        var trust: SecTrust?
        let policy = SecPolicyCreateSSL(true, host as CFString)
        
        // Convert to CFArray for the certificates parameter
        let certificates = [certificate] as CFArray
        let status = SecTrustCreateWithCertificates(certificates, policy, &trust)
        
        guard status == errSecSuccess, let trust = trust else {
            result(false)
            return
        }
        
        // Set custom CA as anchor
        let anchorCertificates = [customCA] as CFArray
        SecTrustSetAnchorCertificates(trust, anchorCertificates)
        
        // Evaluate trust
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(trust, &error)
        
        if let error = error {
            print("Certificate validation error: \(error)")
            result(false)
        } else {
            result(isValid)
        }
    }
    
    private func getCertificateInfo(result: @escaping FlutterResult) {
        let info: [String: Any] = [
            "caLoaded": customCA != nil,
            "proxyStatus": "active"
        ]
        result(info)
    }
}

//import Foundation
//import Network
//
//class CertificateManagerPlugin: NSObject, FlutterPlugin {
//    private var customCA: SecCertificate?
//    private var customURLSessionConfiguration: URLSessionConfiguration?
//    var minVersion: String = ""
//    var maxVersion: String = ""
//    
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(name: "certificate_manager", binaryMessenger: registrar.messenger())
//        let instance = CertificateManagerPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }
//    
//    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        switch call.method {
//        case "setCustomCA":
//            if let args = call.arguments as? [String: Any],
//               let caCert = args["caCert"] as? String {
//                setCustomCA(caCertPem: caCert, result: result)
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENT", message: "CA certificate is required", details: nil))
//            }
//        case "setupCertificateValidation":
//            setupCertificateValidation(result: result)
//        case "validateCertificate":
//            if let args = call.arguments as? [String: Any],
//               let host = args["host"] as? String,
//               let certificate = args["certificate"] as? String {
//                validateCertificate(host: host, certificatePem: certificate, result: result)
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENT", message: "Host and certificate are required", details: nil))
//            }
//        case "getCertificateInfo":
//            getCertificateInfo(result: result)
//        case "configureTLSVersion":
//            if let args = call.arguments as? [String: Any],
//               let minVersion = args["minVersion"] as? String {
//                if #available(iOS 13.0, *) {
//                    configureTLSVersion(minVersion: minVersion, result: result)
//                } else {
//                    // Fallback on earlier versions
//                }
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENT", message: "Minimum TLS version is required", details: nil))
//            }
//        case "createSecureURLSession":
//            createSecureURLSession(result: result)
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//    
//    private func setCustomCA(caCertPem: String, result: @escaping FlutterResult) {
//        // Remove PEM headers/footers and convert to base64 data
//        let pemContent = caCertPem
//            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
//            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
//            .replacingOccurrences(of: "\n", with: "")
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard let data = Data(base64Encoded: pemContent) else {
//            result(FlutterError(code: "CA_LOAD_ERROR", message: "Failed to decode base64 certificate data", details: nil))
//            return
//        }
//        
//        let cfData = data as CFData
//        guard let certificate = SecCertificateCreateWithData(nil, cfData) else {
//            result(FlutterError(code: "CA_LOAD_ERROR", message: "Failed to create certificate from data", details: nil))
//            return
//        }
//        
//        customCA = certificate
//        result(true)
//    }
//    
//    private func setupCertificateValidation(result: @escaping FlutterResult) {
//        // Create custom URL session configuration with TLS 1.2+ enforcement
//        let config = URLSessionConfiguration.default
//        
//        // Configure TLS settings
//        if #available(iOS 13.0, *) {
//            config.tlsMinimumSupportedProtocolVersion = .TLSv12
//        } else {
//            // Fallback on earlier versions
//        }
//        if #available(iOS 13.0, *) {
//            config.tlsMaximumSupportedProtocolVersion = .TLSv13
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        // Store the configuration for later use
//        customURLSessionConfiguration = config
//        
//        result(true)
//    }
//    
//    @available(iOS 13.0, *)
//    private func configureTLSVersion(minVersion: String, result: @escaping FlutterResult) {
//        let config = customURLSessionConfiguration ?? URLSessionConfiguration.default
//        
//        switch minVersion.lowercased() {
//        case "1.2", "tls12":
//            if #available(iOS 13.0, *) {
//                config.tlsMinimumSupportedProtocolVersion = .TLSv12
//            } else {
//                // Fallback on earlier versions
//            }
//            config.tlsMaximumSupportedProtocolVersion = .TLSv13
//        case "1.3", "tls13":
//            config.tlsMinimumSupportedProtocolVersion = .TLSv13
//            config.tlsMaximumSupportedProtocolVersion = .TLSv13
//        default:
//            result(FlutterError(code: "INVALID_TLS_VERSION", message: "Supported versions: 1.2, 1.3", details: nil))
//            return
//        }
//        
//        customURLSessionConfiguration = config
//        result(true)
//    }
//    
//    private func createSecureURLSession(result: @escaping FlutterResult) {
//        guard let config = customURLSessionConfiguration else {
//            result(FlutterError(code: "NO_CONFIG", message: "Call setupCertificateValidation first", details: nil))
//            return
//        }
//        
//        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
//        
//        // You can store this session for use in your app
//        // For now, we'll just return success
//        result(true)
//    }
//    
//    private func validateCertificate(host: String, certificatePem: String, result: @escaping FlutterResult) {
//        guard let customCA = customCA else {
//            result(false)
//            return
//        }
//        
//        // Remove PEM headers/footers and convert to base64 data
//        let pemContent = certificatePem
//            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
//            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
//            .replacingOccurrences(of: "\n", with: "")
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard let data = Data(base64Encoded: pemContent),
//              let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
//            result(FlutterError(code: "VALIDATION_ERROR", message: "Invalid certificate format", details: nil))
//            return
//        }
//        
//        // Create trust object
//        var trust: SecTrust?
//        let policy = SecPolicyCreateSSL(true, host as CFString)
//        
//        // Convert to CFArray for the certificates parameter
//        let certificates = [certificate] as CFArray
//        let status = SecTrustCreateWithCertificates(certificates, policy, &trust)
//        
//        guard status == errSecSuccess, let trust = trust else {
//            result(false)
//            return
//        }
//        
//        // Set custom CA as anchor
//        let anchorCertificates = [customCA] as CFArray
//        SecTrustSetAnchorCertificates(trust, anchorCertificates)
//        
//        // Evaluate trust
//        var error: CFError?
//        let isValid = SecTrustEvaluateWithError(trust, &error)
//        
//        if let error = error {
//            print("Certificate validation error: \(error)")
//            result(false)
//        } else {
//            result(isValid)
//        }
//    }
//    
//    private func getCertificateInfo(result: @escaping FlutterResult) {
//        let tlsVersion = getTLSVersionString()
//        let info: [String: Any] = [
//            "caLoaded": customCA != nil,
//            "proxyStatus": "active",
//            "tlsMinVersion": tlsVersion.min,
//            "tlsMaxVersion": tlsVersion.max,
//            "sessionConfigured": customURLSessionConfiguration != nil
//        ]
//        result(info)
//    }
//    
//    private func getTLSVersionString() -> (min: String, max: String) {
//      
//        guard let config = customURLSessionConfiguration else {
//            return (min: "default", max: "default")
//        }
//        
//   
//        
//        if #available(iOS 13.0, *) {
//            switch config.tlsMinimumSupportedProtocolVersion {
//            case .TLSv12:
//                minVersion = "TLS 1.2"
//            case .TLSv13:
//                minVersion = "TLS 1.3"
//            default:
//                minVersion = "default"
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        if #available(iOS 13.0, *) {
//            switch config.tlsMaximumSupportedProtocolVersion {
//            case .TLSv12:
//                maxVersion = "TLS 1.2"
//            case .TLSv13:
//                maxVersion = "TLS 1.3"
//            default:
//                maxVersion = "default"
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        return (min: minVersion, max: maxVersion)
//    }
//}
//
//// MARK: - URLSessionDelegate
//extension CertificateManagerPlugin: URLSessionDelegate {
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        
//        guard let serverTrust = challenge.protectionSpace.serverTrust,
//              let customCA = customCA else {
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//        
//        // Set custom CA as anchor
//        let anchorCertificates = [customCA] as CFArray
//        SecTrustSetAnchorCertificates(serverTrust, anchorCertificates)
//        
//        // Evaluate trust
//        var error: CFError?
//        let isValid = SecTrustEvaluateWithError(serverTrust, &error)
//        
//        if isValid {
//            let credential = URLCredential(trust: serverTrust)
//            completionHandler(.useCredential, credential)
//        } else {
//            print("Custom certificate validation failed: \(error?.localizedDescription ?? "Unknown error")")
//            completionHandler(.cancelAuthenticationChallenge, nil)
//        }
//    }
//}
