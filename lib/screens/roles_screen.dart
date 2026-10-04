import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/role_controller.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  static const routeName = '/roles';

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  void initState() {
    super.initState();
    RoleController.instance.addListener(_onRole);
    RoleController.instance.load();
  }

  @override
  void dispose() {
    RoleController.instance.removeListener(_onRole);
    super.dispose();
  }

  void _onRole() {
    if (mounted) setState(() {});
  }

  Future<void> _setRole(UserRole role) async {
    await RoleController.instance.setRole(role);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Local role set to ${role.label}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = RoleController.instance.role;
    return Scaffold(
      appBar: AppBar(title: const Text('Roles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Local role toggle. This is not Firebase Auth — anyone with the phone can switch.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Staff can add shipments and update status. Management also sees the dashboard totals.',
          ),
          const SizedBox(height: 16),
          RadioGroup<UserRole>(
            groupValue: current,
            onChanged: (value) {
              if (value != null) _setRole(value);
            },
            child: const Column(
              children: [
                RadioListTile<UserRole>(
                  title: Text('Staff'),
                  subtitle: Text('Yard floor'),
                  value: UserRole.staff,
                ),
                RadioListTile<UserRole>(
                  title: Text('Management'),
                  subtitle: Text('Totals and the dashboard'),
                  value: UserRole.management,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
