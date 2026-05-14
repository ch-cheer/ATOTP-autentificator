import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'data/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final db = ref.watch(dbProvider);
  return db.getAllClients();
});

final isClientsEmptyProvider = FutureProvider<bool>((ref) {
  final clientsAsync = ref.watch(clientsProvider);
  return clientsAsync.when(
    data: (clients) => clients.isEmpty,
    loading: () => false,
    error: (_, _) => false,
  );
});

final servicesProvider = FutureProvider<List<ATOTPData>>((ref) async {
  final db = ref.watch(dbProvider);
  return db.getAllServices();
});

const _themeModeKey = 'app_theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    
    state = ThemeMode.values.firstWhere(
      (mode) => mode.index == index,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    state = mode;
  }

  void toggleTheme() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(next);
  }
  
  void setSystemTheme() => setTheme(ThemeMode.system);
}