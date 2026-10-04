import 'package:flutter/material.dart';

import '../models/shipment_status.dart';
import '../services/local_store.dart';
import '../services/role_controller.dart';
import 'roles_screen.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<ManagementDashboardScreen> createState() =>
      _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  LedgerTotals? _totals;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    RoleController.instance.addListener(_onRole);
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
    await RoleController.instance.load();
    if (!RoleController.instance.isManagement) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _totals = null;
      });
      return;
    }
    try {
      final totals = await LocalStore.instance.totals();
      if (!mounted) return;
      setState(() {
        _totals = totals;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Management dashboard')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (!RoleController.instance.isManagement) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The dashboard is for the management role.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(RolesScreen.routeName);
                  await _load();
                },
                child: const Text('Switch role'),
              ),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(child: Text('Could not load totals.\n$_error'));
    }
    final totals = _totals;
    if (totals == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Cost total'),
            subtitle: Text(formatMoney(totals.cost)),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Containers'),
            subtitle: Text('${totals.containers}'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Shipments'),
            subtitle: Text('${totals.items}'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Shipments by status',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        for (final status in ShipmentStatus.values)
          ListTile(
            dense: true,
            title: Text(status.label),
            trailing: Text('${totals.itemsByStatus[status] ?? 0}'),
          ),
      ],
    );
  }
}
