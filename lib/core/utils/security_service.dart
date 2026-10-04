import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  final FlutterSecureStorage _storage;

  SecurityService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _pinKey = 'chronicle_user_pin_hash';

  String hashPin(String pin) {
    final bytes = utf8.encode('chronicle_salt_$pin');
    return sha256.convert(bytes).toString();
  }

  Future<void> savePin(String pin) async {
    final hash = hashPin(pin);
    await _storage.write(key: _pinKey, value: hash);
  }

  Future<bool> verifyPin(String enteredPin) async {
    final savedHash = await _storage.read(key: _pinKey);
    if (savedHash == null) return true; // No pin set
    return savedHash == hashPin(enteredPin);
  }

  Future<bool> isPinSet() async {
    final savedHash = await _storage.read(key: _pinKey);
    return savedHash != null && savedHash.isNotEmpty;
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
  }
}
