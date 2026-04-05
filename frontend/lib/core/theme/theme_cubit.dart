import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final dark = p.getBool('dark_mode') ?? false;
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    // Only emit if different — prevents a spurious MaterialApp rebuild
    // mid-navigation that causes the _dependents.isEmpty red-screen crash.
    if (mode != state) emit(mode);
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', !isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}