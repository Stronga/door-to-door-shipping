import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/shipping_container.dart';
import '../services/local_store.dart';
import 'add_shipment_screen.dart';
import 'item_detail_screen.dart';

class ContainerDetailScreen extends StatefulWidget {
  const ContainerDetailScreen({super.key});

  static const routeName = '/container';

  @override
  State<ContainerDetailScreen> createState() => _ContainerDetailScreenState();
}

class _ContainerDetailScreenState extends State<ContainerDetailScreen> {
  String? _id;
  var _bound = false;
  ShippingContainer? _container;
  List<Item> _items = const [];
  var _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final id = args is String ? args : null;
    if (_bound && id == _id) return;
    _bound = true;
    _id = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final id = _id;
    if (id == null) {
      setState(() {
        _loading = false;
        _container = null;
        _items = const [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final container = await LocalStore.instance.getContainer(id);
      final items = container == null
          ? const <Item>[]
          : await LocalStore.instance.itemsInContainer(id);
      if (!mounted) return;
      setState(() {
        _container = container;
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  double get _costTotal =>
      _items.fold<double>(0, (sum, item) => sum + (item.cost ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_container?.name ?? 'Container detail')),
      floatingActionButton: _container == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  AddShipmentScreen.routeName,
                  arguments: _container!.id,
                );
                await _load();
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add shipment'),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_id == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Open a container from the home list.'),
        ),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text('Could not load this container.\n$_error'));
    }
    final container = _container;
    if (container == null) {
      return const Center(child: Text('Container not found.'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        ListTile(
          title: const Text('Carrier / forwarder'),
          subtitle: Text(container.carrier ?? '—'),
        ),
        ListTile(
          title: const Text('Tracking #'),
          subtitle: Text(container.trackingNumber ?? '—'),
        ),
        ListTile(
          title: const Text('Tracking link'),
          subtitle: Text(container.trackingLink ?? '—'),
        ),
        ListTile(
          title: const Text('Status'),
          subtitle: Text(container.status.label),
        ),
        ListTile(
          title: const Text('Cost total'),
          subtitle: Text(formatMoney(_costTotal)),
        ),
        const Divider(),
        Text(
          'Items (${_items.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          const Text('No shipments in this container yet.')
        else
          for (final item in _items)
            Card(
              child: ListTile(
                title: Text(item.receiverName),
                subtitle: Text(
                  '${item.destination ?? 'No destination'} · ${item.status.label}',
                ),
                trailing: Text(formatMoney(item.cost)),
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    ItemDetailScreen.routeName,
                    arguments: item.id,
                  );
                  await _load();
                },
              ),
            ),
      ],
    );
  }
}
