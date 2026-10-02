import 'package:flutter/material.dart';

class AddShipmentScreen extends StatelessWidget {
  const AddShipmentScreen({super.key});

  static const routeName = '/add-shipment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add shipment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Camera → OCR → confirm → cost → save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('OCR / camera coming'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera + on-device OCR not implemented yet'),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture label (stub)'),
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Receiver name',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
              ),
              enabled: false,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
