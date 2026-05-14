import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:convert';
import 'dart:math';

class DbKeyManager {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'db_encryption_key_v1';

  static Future<String> getOrCreateKey() async {
    var key = await _storage.read(key: _keyName);
    
    if (key == null || key.isEmpty) {
      key = _generateSecureKey();
      await _storage.write(key: _keyName, value: key);
    }
    
    return key;
  }

  static String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String escapeKey(String key) => key.replaceAll("'", "''");

  static bool debugCheckCipherEnabled(Database db) {
    try {
      final result = db.select('PRAGMA cipher;');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}