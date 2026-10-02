import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  static const _nav = <_NavItem>[
    _NavItem('Login', '/login', Icons.login),
    _NavItem('Home', '/home', Icons.home),
    _NavItem('Container detail', '/container', Icons.inventory_2),
    _NavItem('Add shipment', '/add-shipment', Icons.add_a_photo),
    _NavItem('Item detail', '/item', Icons.local_shipping),
    _NavItem('Search', '/search', Icons.search),
    _NavItem('Management dashboard', '/dashboard', Icons.dashboard),
    _NavItem('Roles', '/roles', Icons.manage_accounts),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Containers')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Shipping Ledger',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            for (final item in _nav)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                onTap: () {
                  Navigator.pop(context);
                  if (item.route == '/home') return;
                  Navigator.of(context).pushNamed(item.route);
                },
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Containers (placeholder)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('No containers yet — Firestore not connected.'),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Sample Container A'),
              subtitle: const Text('status: received · stub'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed('/container'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick links',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final item in _nav.where((n) => n.route != '/home'))
            ListTile(
              dense: true,
              leading: Icon(item.icon, size: 20),
              title: Text(item.label),
              onTap: () => Navigator.of(context).pushNamed(item.route),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/add-shipment'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String route;
  final IconData icon;
  const _NavItem(this.label, this.route, this.icon);
}
