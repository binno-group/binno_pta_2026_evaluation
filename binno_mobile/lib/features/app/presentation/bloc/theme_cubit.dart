import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The cubit managing the app theme (light/dark).
///
/// The default is **light** (design §: the app is used in sunlight). The
/// choice is stored in `SharedPreferences`, so it survives restarts. It is
/// a single source for the whole app, which is why it lives in
/// `features/app`.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _restore();
  }

  static const _key = 'app_theme_mode';

  bool get isDark => state == ThemeMode.dark;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (prefs.getString(_key)) {
        case 'dark':
          emit(ThemeMode.dark);
        case 'light':
          emit(ThemeMode.light);
      }
    } catch (_) {
      // If reading fails, the default light stays.
    }
  }

  Future<void> setDark(bool dark) async {
    emit(dark ? ThemeMode.dark : ThemeMode.light);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, dark ? 'dark' : 'light');
    } catch (_) {
      // Even if saving fails, the current session still works.
    }
  }

  Future<void> toggle() => setDark(!isDark);
}
