import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('themeMode');
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void toggleTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isDarkMode) {
      _themeMode = ThemeMode.dark;
      await prefs.setString('themeMode', 'dark');
    } else {
      _themeMode = ThemeMode.light;
      await prefs.setString('themeMode', 'light');
    }
    notifyListeners();
  }

  void setSystemTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.system;
    await prefs.remove('themeMode');
    notifyListeners();
  }
}