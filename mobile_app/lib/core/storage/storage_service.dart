import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveSession({
    required String token,
    required String role,
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    await init();
    await _prefs?.setString(AppConstants.keySessionToken, token);
    await _prefs?.setString(AppConstants.keyUserRole, role);
    await _prefs?.setString(AppConstants.keyUserId, userId);
    await _prefs?.setString(AppConstants.keyUserData, jsonEncode(userData));
  }

  static String? getSessionToken() {
    return _prefs?.getString(AppConstants.keySessionToken);
  }

  static String? getUserRole() {
    return _prefs?.getString(AppConstants.keyUserRole);
  }

  static String? getUserId() {
    return _prefs?.getString(AppConstants.keyUserId);
  }

  static Map<String, dynamic>? getUserData() {
    final raw = _prefs?.getString(AppConstants.keyUserData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    await init();
    await _prefs?.remove(AppConstants.keySessionToken);
    await _prefs?.remove(AppConstants.keyUserRole);
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserData);
  }

  static String getLanguage() {
    return _prefs?.getString(AppConstants.keyLanguage) ?? 'en';
  }

  static Future<void> setLanguage(String lang) async {
    await init();
    await _prefs?.setString(AppConstants.keyLanguage, lang);
  }
}

