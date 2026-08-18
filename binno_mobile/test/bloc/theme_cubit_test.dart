import 'package:binno/features/app/presentation/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests for `ThemeCubit`: theme state and persistence (§10).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('the default state is light', () {
    final cubit = ThemeCubit();
    expect(cubit.state, ThemeMode.light);
    expect(cubit.isDark, isFalse);
  });

  test('setDark(true) switches to dark', () async {
    final cubit = ThemeCubit();
    await cubit.setDark(true);
    expect(cubit.state, ThemeMode.dark);
    expect(cubit.isDark, isTrue);
  });

  test('toggle flips the state', () async {
    final cubit = ThemeCubit();
    await cubit.toggle();
    expect(cubit.isDark, isTrue);
    await cubit.toggle();
    expect(cubit.isDark, isFalse);
  });

  test('the choice is stored in SharedPreferences', () async {
    final cubit = ThemeCubit();
    await cubit.setDark(true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'dark');
  });

  test('a stored dark theme is restored', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
    final cubit = ThemeCubit();
    // Konstruktordagi _restore() asinxron — kutamiz.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state, ThemeMode.dark);
  });
}
