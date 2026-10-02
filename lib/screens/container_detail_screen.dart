import 'package:flutter/material.dart';

class ContainerDetailScreen extends StatelessWidget {
  const ContainerDetailScreen({super.key});

  static const routeName = '/container';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Container detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Name / ID'),
            subtitle: Text('Sample Container A (stub)'),
          ),
          ListTile(
            title: Text('Carrier / forwarder'),
            subtitle: Text('—'),
          ),
          ListTile(
            title: Text('Tracking # / link'),
            subtitle: Text('—'),
          ),
          ListTile(
            title: Text('Status'),
            subtitle: Text('received'),
          ),
          ListTile(
            title: Text('Cost total'),
            subtitle: Text('—'),
          ),
          Divider(),
          Text('Items in this container will list here.'),
        ],
      ),
    );
  }
}
