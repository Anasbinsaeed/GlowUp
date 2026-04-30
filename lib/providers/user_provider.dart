import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const _nameKey = 'user_name';
  static const _ageKey = 'user_age';
  static const _currencyKey = 'user_currency';

  String _name = '';
  int? _age;
  String _currency = '\$';

  String get name => _name;
  int? get age => _age;
  String get currency => _currency;
  bool get hasName => _name.trim().isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? '';
    _age = prefs.getInt(_ageKey);
    _currency = prefs.getString(_currencyKey) ?? '\$';
    notifyListeners();
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name.trim());
    _name = name.trim();
    notifyListeners();
  }

  Future<void> saveDetails({required int age, required String currency}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, age);
    await prefs.setString(_currencyKey, currency);
    _age = age;
    _currency = currency;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_ageKey);
    await prefs.remove(_currencyKey);
    _name = '';
    _age = null;
    _currency = '\$';
    notifyListeners();
  }
}
