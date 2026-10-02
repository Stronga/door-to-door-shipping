import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key});

  static const routeName = '/item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('Receiver'), subtitle: Text('—')),
          ListTile(title: Text('Phone'), subtitle: Text('—')),
          ListTile(title: Text('Destination'), subtitle: Text('—')),
          ListTile(title: Text('Package type'), subtitle: Text('box')),
          ListTile(title: Text('Cost'), subtitle: Text('—')),
          ListTile(title: Text('Status'), subtitle: Text('received')),
          ListTile(title: Text('Notes'), subtitle: Text('—')),
          ListTile(
            title: Text('Media'),
            subtitle: Text('Photo / video placeholder'),
          ),
        ],
      ),
    );
  }
}
