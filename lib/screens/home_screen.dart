import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/local_store.dart';
import '../services/role_controller.dart';
import '../widgets/create_container_dialog.dart';
import 'add_shipment_screen.dart';
import 'container_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ContainerSummary> _containers = const [];
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    RoleController.instance.addListener(_onRole);
    RoleController.instance.load();
    _load();
  }

  @override
  void dispose() {
    RoleController.instance.removeListener(_onRole);
    super.dispose();
  }

  void _onRole() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final containers = await LocalStore.instance.listContainers();
      if (!mounted) return;
      setState(() {
        _containers = containers;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _createContainer() async {
    final created = await showCreateContainerDialog(context);
    if (created != null) await _load();
  }

  Future<void> _openAdd({String? containerId}) async {
    await Navigator.of(context).pushNamed(
      AddShipmentScreen.routeName,
      arguments: containerId,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final management = RoleController.instance.isManagement;
    final nav = <_NavItem>[
      const _NavItem('Search', '/search', Icons.search),
      if (management)
        const _NavItem('Management dashboard', '/dashboard', Icons.dashboard),
      const _NavItem('Roles', '/roles', Icons.manage_accounts),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Containers'),
        actions: [
          IconButton(
            tooltip: 'New container',
            onPressed: _createContainer,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Shipping Ledger',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    RoleController.instance.role == UserRole.management
                        ? 'Management (local)'
                        : 'Staff (local)',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            for (final item in nav)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.of(context).pushNamed(item.route);
                  if (mounted) setState(() {});
                },
              ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Could not load containers.\n$_error'));
    }
    if (_containers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No containers yet.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _createContainer,
                icon: const Icon(Icons.add),
                label: const Text('Create a container'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: _containers.length,
        itemBuilder: (context, index) {
          final summary = _containers[index];
          final container = summary.container;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(container.name),
              subtitle: Text(
                '${container.status.label} · ${summary.itemCount} items · ${formatMoney(summary.costTotal)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  ContainerDetailScreen.routeName,
                  arguments: container.id,
                );
                await _load();
              },
            ),
          );
        },
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
