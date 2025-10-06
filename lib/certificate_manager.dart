import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'trust_store.dart';

class CertificateManager {
  static final CertificateManager _instance = CertificateManager._internal();
  static CertificateManager get instance => _instance;
  CertificateManager._internal();

  late final TrustStore _trustStore;
  bool _isInitialized = false;
  static const MethodChannel _channel = MethodChannel('certificate_manager');

  Future<void> initialize() async {
    if (_isInitialized) return;

    _trustStore = TrustStore();
    await _trustStore.initialize();

    // Load custom CA certificate
    await _loadCustomCA();
    
    _isInitialized = true;
  }

  // Future<void> _loadCustomCA() async {
  //   try {
  //     // Load CA certificate from assets
  //     final caData = await rootBundle.loadString('assets/certs/c1-ca.crt');
  //     await _trustStore.addCertificate('custom_ca', caData);
      
  //     // Configure platform-specific certificate validation
  //     await _channel.invokeMethod('setCustomCA', {'caCert': caData});
  //   } catch (e) {
  //     print('Error loading custom CA: $e');
  //   }
  // }

  Future<void> _loadCustomCA() async {
  try {
    // Try loading as string first (for PEM format)
    String caString;
    try {
      caString = await rootBundle.loadString('assets/certs/c1-ca.crt');
      
      // Validate it's a proper PEM certificate
      if (!caString.contains('-----BEGIN CERTIFICATE-----')) {
        throw FormatException('Not a PEM certificate');
      }
    } catch (e) {
      // If string loading fails, try loading as binary
      final caData = await rootBundle.load('assets/certs/c1-ca.crt');
      final caBytes = caData.buffer.asUint8List();
      caString = _bytesToPem(caBytes);
    }
    
    await _trustStore.addCertificate('custom_ca', caString);
    await _channel.invokeMethod('setCustomCA', {'caCert': caString});
  } catch (e) {
    print('Error loading custom CA: $e');
  }
}

String _bytesToPem(Uint8List bytes) {
  final base64Cert = base64.encode(bytes);
  return '-----BEGIN CERTIFICATE-----\n$base64Cert\n-----END CERTIFICATE-----';
}

  Future<void> setupCustomCertificateValidation() async {
    try {
      await _channel.invokeMethod('setupCertificateValidation');
    } catch (e) {
      print('Error setting up certificate validation: $e');
    }
  }

  Future<bool> validateCertificate(String host, String certificate) async {
    try {
      // Check if certificate is in trust store
      if (await _trustStore.isTrusted(certificate)) {
        return true;
      }

      // Validate against custom CA
      final result = await _channel.invokeMethod('validateCertificate', {
        'host': host,
        'certificate': certificate,
      });
      
      if (result == true) {
        // Store the validated certificate
        await _trustStore.addCertificate(host, certificate);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Certificate validation error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getCertificateInfo() async {
    try {
      final platformInfo = await _channel.invokeMethod('getCertificateInfo');
      final storeInfo = await _trustStore.getInfo();
      
      return {
        ...platformInfo,
        ...storeInfo,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'caLoaded': false,
        'certificateCount': 0,
        'proxyStatus': 'unknown',
      };
    }
  }
}