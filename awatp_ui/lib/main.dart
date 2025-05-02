import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'threat_dashboard.dart';
import 'recon_page.dart'; // 👈 Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWATP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ScanPage(),
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _urlController = TextEditingController();
  final List<String> _scanModules = ['sqli', 'xss', 'ssti'];
  final Map<String, bool> _selectedModules = {
    'sqli': false,
    'xss': false,
    'ssti': false,
  };
  Map<String, dynamic> _scanResults = {};
  bool _isLoading = false;

  Future<void> _startScan() async {
    final urls = _urlController.text
        .split(',')
        .map((e) => e.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    final selected = _selectedModules.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (urls.isEmpty || selected.isEmpty) return;

    setState(() {
      _isLoading = true;
      _scanResults.clear();
    });

    final response = await http.post(
      Uri.parse('http://localhost:5000/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'urls': urls,
        'modules': selected,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _scanResults = jsonDecode(response.body);
      });
    } else {
      setState(() {
        _scanResults = {'error': 'Scan failed: ${response.statusCode}'};
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _downloadReport(String filename, Map<String, dynamic> data) {
    final blob = html.Blob([jsonEncode(data)], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AWATP Web Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter target URLs (comma separated)'),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://example.com, https://test.com',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _scanModules.map((module) {
                return FilterChip(
                  label: Text(module.toUpperCase()),
                  selected: _selectedModules[module]!,
                  onSelected: (value) {
                    setState(() {
                      _selectedModules[module] = value;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _startScan,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Start Scan'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Open Recon Module'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReconPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _scanResults.isEmpty
                  ? const Text('No scan results yet.')
                  : ListView(
                      children: _scanResults.entries.map((entry) {
                        final data = entry.value;
                        final filename =
                            'scan_${entry.key.replaceAll(RegExp(r"https?://"), "").replaceAll("/", "_")}_${DateTime.now().toIso8601String()}.json';
                        return Card(
                          child: ListTile(
                            title: Text(entry.key),
                            subtitle: Text(jsonEncode(data)),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadReport(filename, data),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

