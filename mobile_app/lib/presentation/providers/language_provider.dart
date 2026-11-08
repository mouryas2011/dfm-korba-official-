import 'package:flutter/material.dart';
import '../../core/storage/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isHindi => _locale.languageCode == 'hi';

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() {
    final lang = StorageService.getLanguage();
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('hi');
      await StorageService.setLanguage('hi');
    } else {
      _locale = const Locale('en');
      await StorageService.setLanguage('en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale loc) async {
    _locale = loc;
    await StorageService.setLanguage(loc.languageCode);
    notifyListeners();
  }
}

