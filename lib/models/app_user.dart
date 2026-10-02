import 'user_role.dart';

class AppUser {
  final String id;
  final String displayName;
  final UserRole role;
  final bool active;

  const AppUser({
    required this.id,
    required this.displayName,
    this.role = UserRole.staff,
    this.active = true,
  });
}
