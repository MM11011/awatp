import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _urlController = TextEditingController();
  final Set<String> _selectedModules = {'sqli', 'xss', 'ssti'};
  Map<String, dynamic> _scanResults = {};

  Future<void> _startScan() async {
    final urls = _urlController.text
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    final response = await http.post(
      Uri.parse('http://localhost:5000/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'urls': urls, 'modules': _selectedModules.toList()}),
    );

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body);
      setState(() {
        _scanResults = results;
      });

      // Show a modal if any result contains an error
      final blocked = results.entries.firstWhere(
        (entry) => entry.value is Map && entry.value.containsKey('error'),
        orElse: () => MapEntry('', null),
      );

      if (blocked.key.isNotEmpty) {
        _showBlockedModal(blocked.key, blocked.value['error']);
      }
    } else {
      // Handle error
      print('Scan request failed with status: ${response.statusCode}');
    }
  }

  void _showBlockedModal(String url, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Scan Blocked'),
        content: Text('The domain "$url" was blocked.\n\n$message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String url, dynamic result) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(url),
        subtitle: Text(jsonEncode(result)),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // TODO: Implement per-scan JSON export
          },
        ),
      ),
    );
  }

  Widget _buildModuleToggle(String label, String module) {
    return FilterChip(
      label: Text(label.toUpperCase()),
      selected: _selectedModules.contains(module),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedModules.add(module);
          } else {
            _selectedModules.remove(module);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWATP Web Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter target URLs (comma separated)',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildModuleToggle('SQLi', 'sqli'),
                _buildModuleToggle('XSS', 'xss'),
                _buildModuleToggle('SSTI', 'ssti'),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startScan,
              child: const Text('Start Scan'),
            ),
            const SizedBox(height: 20),
            ..._scanResults.entries.map((e) => _buildResultCard(e.key, e.value)),
          ],
        ),
      ),
    );
  }
}






