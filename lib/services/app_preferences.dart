import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';

class AppPreferences {
  AppPreferences._();

  static const _themeModeKey = 'theme_mode';
  static const _authRoleKey = 'auth_role';
  static const _authTokenKey = 'auth_token';
  static const _authEmailKey = 'auth_email';
  static const _authFirstNameKey = 'auth_first_name';
  static const _authLastNameKey = 'auth_last_name';
  static const _authDisplayNameKey = 'auth_display_name';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);

    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, raw);
  }

  static Future<void> saveAuthRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authRoleKey, role);
  }

  static Future<String?> loadAuthRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authRoleKey);
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authRoleKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_authEmailKey);
    await prefs.remove(_authFirstNameKey);
    await prefs.remove(_authLastNameKey);
    await prefs.remove(_authDisplayNameKey);
  }

  static Future<void> saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authEmailKey, user.email);
    await prefs.setString(_authDisplayNameKey, user.name);
    if (user.firstName != null) {
      await prefs.setString(_authFirstNameKey, user.firstName!);
    } else {
      await prefs.remove(_authFirstNameKey);
    }
    if (user.lastName != null) {
      await prefs.setString(_authLastNameKey, user.lastName!);
    } else {
      await prefs.remove(_authLastNameKey);
    }
  }

  static Future<AppUser?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_authEmailKey)?.trim();
    final role = prefs.getString(_authRoleKey)?.trim();
    final displayName = prefs.getString(_authDisplayNameKey)?.trim();

    if (email == null ||
        email.isEmpty ||
        role == null ||
        role.isEmpty ||
        displayName == null ||
        displayName.isEmpty) {
      return null;
    }

    return AppUser(
      id: 'stored_${email.hashCode}',
      email: email,
      password: '',
      firstName: prefs.getString(_authFirstNameKey)?.trim(),
      lastName: prefs.getString(_authLastNameKey)?.trim(),
      name: displayName,
      type: _mapUserType(role),
    );
  }

  static UserType _mapUserType(String role) {
    switch (role) {
      case 'VETERINARIAN':
        return UserType.veterinarian;
      case 'ADMIN':
        return UserType.shelter;
      default:
        return UserType.petOwner;
    }
  }
}
