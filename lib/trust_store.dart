import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class TrustStore {
  late File _storeFile;
  Map<String, String> _certificates = {};

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _storeFile = File('${directory.path}/trust_store.json');
    
    await _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      if (await _storeFile.exists()) {
        final content = await _storeFile.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        _certificates = Map<String, String>.from(data);
      }
    } catch (e) {
      print('Error loading trust store: $e');
      _certificates = {};
    }
  }

  Future<void> _saveCertificates() async {
    try {
      final content = jsonEncode(_certificates);
      await _storeFile.writeAsString(content);
    } catch (e) {
      print('Error saving trust store: $e');
    }
  }

  Future<void> addCertificate(String identifier, String certificate) async {
    final hash = sha256.convert(utf8.encode(certificate)).toString();
    _certificates[identifier] = hash;
    await _saveCertificates();
  }

  Future<bool> isTrusted(String certificate) async {
    final hash = sha256.convert(utf8.encode(certificate)).toString();
    return _certificates.containsValue(hash);
  }

  Future<void> removeCertificate(String identifier) async {
    _certificates.remove(identifier);
    await _saveCertificates();
  }

  Future<void> clearAll() async {
    _certificates.clear();
    await _saveCertificates();
  }

  Future<Map<String, dynamic>> getInfo() async {
    return {
      'certificateCount': _certificates.length,
      'certificates': _certificates.keys.toList(),
    };
  }
}