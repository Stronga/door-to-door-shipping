import 'package:flutter/material.dart';

class ManagementDashboardScreen extends StatelessWidget {
  const ManagementDashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Management dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Cost totals'),
              subtitle: const Text('— (stub)'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Containers by status'),
              subtitle: const Text('— (stub)'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Reports'),
              subtitle: const Text('Coming later'),
            ),
          ),
        ],
      ),
    );
  }
}
