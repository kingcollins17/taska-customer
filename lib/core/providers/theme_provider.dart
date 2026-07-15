import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Synchronously read from the already-opened Hive box
    final box = Hive.box(HiveBox.defaultBox.name);
    final storedTheme = box.get(StorageKey.themeMode.name);

    if (storedTheme == 'light') {
      return ThemeMode.light;
    } else if (storedTheme == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    String modeString = 'system';
    if (mode == ThemeMode.light) {
      modeString = 'light';
    } else if (mode == ThemeMode.dark) {
      modeString = 'dark';
    }
    Hive.box(HiveBox.defaultBox.name).put(StorageKey.themeMode.name, modeString);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

final themeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
