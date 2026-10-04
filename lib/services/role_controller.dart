import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_role.dart';

/// Local stand-in for Firebase Auth roles. Not a real login.
class RoleController extends ChangeNotifier {
  RoleController._();
  static final RoleController instance = RoleController._();

  static const _key = 'local_user_role';

  UserRole role = UserRole.staff;

  bool get isManagement => role == UserRole.management;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    role = raw == UserRole.management.name
        ? UserRole.management
        : UserRole.staff;
    notifyListeners();
  }

  Future<void> setRole(UserRole value) async {
    role = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
