import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'webview_screen.dart';
import 'certificate_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize certificate manager
  await CertificateManager.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom CA WebView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyWebView(),
    );
  }
}