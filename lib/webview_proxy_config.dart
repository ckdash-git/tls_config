import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class WebviewProxyConfig {
  static const MethodChannel _channel = MethodChannel('webview_proxy_config');

  Future<void> webivewProxyConfig(final String proxyHost, final String proxyPort, final String endpoint, final String userIdHash, final String tenantIdHash, final String sessionId) async {
    try {
        await _channel.invokeMethod('setWebivewProxyConfig', <String, dynamic>{
          'proxy_host' : proxyHost,
          'proxy_port' : proxyPort,
          'endpoint' : endpoint,
          'userIdHash' : userIdHash,
          'tenantIdHash' : tenantIdHash,
          'sessionId' : sessionId,
        });
    } on PlatformException catch(e){
      debugPrint("Failed to start proxy : $e");
    }
  }

}