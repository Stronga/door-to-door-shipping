import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/local_store.dart';
import 'item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  List<Item> _results = const [];
  var _searched = false;
  var _busy = false;
  var _generation = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String raw) async {
    final generation = ++_generation;
    final text = raw.trim();
    if (text.isEmpty) {
      setState(() {
        _results = const [];
        _searched = false;
        _busy = false;
      });
      return;
    }
    setState(() => _busy = true);
    try {
      final results = await LocalStore.instance.searchItems(text);
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = results;
        _searched = true;
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _query,
              decoration: InputDecoration(
                hintText: 'Receiver, phone, destination…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _search,
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_searched) {
      return const Center(
        child: Text('Search shipments saved on this device.'),
      );
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No matching shipments.'));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return ListTile(
          title: Text(item.receiverName),
          subtitle: Text(
            [
              if ((item.phone ?? '').isNotEmpty) item.phone,
              if ((item.destination ?? '').isNotEmpty) item.destination,
              item.status.label,
            ].join(' · '),
          ),
          trailing: Text(formatMoney(item.cost)),
          onTap: () async {
            await Navigator.of(context).pushNamed(
              ItemDetailScreen.routeName,
              arguments: item.id,
            );
            await _search(_query.text);
          },
        );
      },
    );
  }
}
