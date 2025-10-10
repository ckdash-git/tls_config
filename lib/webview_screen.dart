import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sslpinning/webview_proxy_config.dart';
import 'certificate_manager.dart';

// class WebViewScreen extends StatefulWidget {
//   const WebViewScreen({super.key});

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final InAppWebViewController _controller;
//   bool _isLoading = true;
  // String _currentUrl = 'https://ztna15.cpcgw01.cachatto.co.in';
  // bool _isProxyConfigured = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _setupWkWebviewProxyConfig();
  // }


// Future<void> _setupWkWebviewProxyConfig() async {

//    try {
//     _isProxyConfigured = true;

//     final String cpcSessionId = '';
      
//      await WebviewProxyConfig().webivewProxyConfig('127.0.0.1', 
//      '9000',
//      'https://ztna15.cpcgw01.cachatto.co.in',
//      '1310097',
//      '475015d',
//      cpcSessionId,);

//       await Future.delayed(const Duration(seconds: 2));

//     } on PlatformException catch (e) {
//       debugPrint('Failed to set proxy: ${e.message}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProxyConfigured = false;
//         });
//       }
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     if (!_isProxyConfigured) {
//       // While waiting for the proxy, show a loading indicator.
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Custom CA WebView'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => _controller.reload(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: _showCertificateInfo,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // URL input
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       hintText: 'Enter URL',
//                       border: OutlineInputBorder(),
//                     ),
//                     onSubmitted: (url) {
//                       setState(() {
//                         _currentUrl = url;
//                       });
//                       _controller.loadUrl(
//                         urlRequest: URLRequest(url: WebUri(url)),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     _controller.loadUrl(
//                       urlRequest: URLRequest(url: WebUri(_currentUrl)),
//                     );
//                   },
//                   child: const Text('Go'),
//                 ),
//               ],
//             ),
//           ),
//           // Loading indicator
//           if (_isLoading)
//             const LinearProgressIndicator(),
//           // WebView
//           Expanded(
//             child: InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
//               initialOptions: InAppWebViewGroupOptions(
//                 crossPlatform: InAppWebViewOptions(
//                   javaScriptEnabled: true,
//                 ),
//               ),
//               onWebViewCreated: (controller) {
//                 _controller = controller;
//               },
//               onLoadStart: (controller, url) {
//                 setState(() {
//                   _isLoading = true;
//                 });
//               },
//               onLoadStop: (controller, url) {
//                 setState(() {
//                   _isLoading = false;
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCertificateInfo() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Certificate Information'),
//         content: FutureBuilder<Map<String, dynamic>>(
//           future: CertificateManager.instance.getCertificateInfo(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               final info = snapshot.data!;
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('CA Loaded: ${info['caLoaded']}'),
//                   Text('Certificates in Store: ${info['certificateCount']}'),
//                   Text('Proxy Status: ${info['proxyStatus']}'),
//                 ],
//               );
//             }
//             return const CircularProgressIndicator();
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MyWebView extends StatefulWidget {
  
  const MyWebView({Key? key}) : super(key: key);
  
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  bool _isProxyConfigured = false;
  String _currentUrl = 'https://ztna15.cpcgw01.cachatto.co.in';
  bool _canGoBack = false;
  bool _canGoForward = false;

    @override
  void initState() {
    super.initState();
    _setupWkWebviewProxyConfig();
  }


  Future<void> _setupWkWebviewProxyConfig() async {

   try {
    _isProxyConfigured = true;

    final String cpcSessionId = '';
      
     await WebviewProxyConfig().webivewProxyConfig('192.168.200.9', 
     '9000',
     'https://ztna15.cpcgw01.cachatto.co.in',
     '1310097',
     '475015d',
     cpcSessionId,);

      await Future.delayed(const Duration(seconds: 2));

    } on PlatformException catch (e) {
      debugPrint('Failed to set proxy: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isProxyConfigured = false;
        });
      }
    }
  }

  // Navigation methods
  void _goBack() {
    if (_canGoBack && _webViewController != null) {
      _webViewController!.goBack();
    }
  }

  void _goForward() {
    if (_canGoForward && _webViewController != null) {
      _webViewController!.goForward();
    }
  }

  void _reload() {
    if (_webViewController != null) {
      _webViewController!.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProxyConfigured) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _canGoBack ? Colors.white : Colors.white54),
            onPressed: _canGoBack ? _goBack : null,
          ),
          // Forward button
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: _canGoForward ? Colors.white : Colors.white54),
            onPressed: _canGoForward ? _goForward : null,
          ),
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _progress < 1.0
              ? LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : Container(),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                print("Loading started: $url");
              },
              onLoadStop: (controller, url) {
                print("Loading finished: $url");
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                // Update navigation buttons when history changes
                _updateNavigationState();
              },
              onLoadError: (controller, url, code, message) {
                print("Load error: $message");
              },
               onReceivedServerTrustAuthRequest:
                        (controller, challenge) async {
                      return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED);

            },
            ),
          ),
        ],
      ),
      // Alternative navigation buttons in bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: _canGoBack ? Colors.blue : Colors.grey),
              onPressed: _canGoBack ? _goBack : null,
              tooltip: 'Back',
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward, color: _canGoForward ? Colors.blue : Colors.grey),
              onPressed: _canGoForward ? _goForward : null,
              tooltip: 'Forward',
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blue),
              onPressed: () {
                if (_webViewController != null) {
                  _webViewController!.loadUrl(
                    urlRequest: URLRequest(url: WebUri(_currentUrl)),
                  );
                }
              },
              tooltip: 'Home',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _reload,
              tooltip: 'Reload',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to update navigation button states
  void _updateNavigationState() async {
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      final canGoForward = await _webViewController!.canGoForward();
      
      if (mounted) {
        setState(() {
          _canGoBack = canGoBack;
          _canGoForward = canGoForward;
        });
      }
    }
  }
}