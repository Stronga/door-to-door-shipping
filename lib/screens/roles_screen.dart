import 'package:flutter/material.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  static const routeName = '/roles';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles / user admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Management only — assign staff vs management roles.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Sample Staff User'),
            subtitle: Text('role: staff · stub'),
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings_outlined),
            title: Text('Sample Manager'),
            subtitle: Text('role: management · stub'),
          ),
        ],
      ),
    );
  }
}
