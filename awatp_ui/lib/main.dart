import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'threat_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWATP Web Scanner',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const ScanPage(),
      debugShowCheckedModeBanner: false,
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
  final Map<String, dynamic> _scanResults = {};
  bool _scanning = false;

  final Map<String, bool> _scanModules = {
    'SQLI': false,
    'XSS': false,
    'SSTI': false,
  };

  Future<void> _runScan() async {
    final urls = _urlController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final selectedModules =
        _scanModules.entries.where((e) => e.value).map((e) => e.key).toList();

    if (urls.isEmpty || selectedModules.isEmpty) {
      return;
    }

    setState(() {
      _scanning = true;
      _scanResults.clear();
    });

    for (final url in urls) {
      setState(() {
        _scanResults[url] = {'status': 'Queued'};
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/scan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'url': url, 'modules': selectedModules}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _scanResults[url] = {'status': 'Success', 'data': data};
          });
        } else {
          setState(() {
            _scanResults[url] = {
              'status': 'Error',
              'message': 'HTTP ${response.statusCode}'
            };
          });
        }
      } catch (e) {
        setState(() {
          _scanResults[url] = {'status': 'Error', 'message': '$e'};
        });
      }
    }

    setState(() {
      _scanning = false;
    });
  }

  void _downloadAllAsZip() {
    for (final entry in _scanResults.entries) {
      if (entry.value['status'] != 'Success') continue;

      final result = entry.value['data'];
      final json = const JsonEncoder.withIndent('  ').convert(result);
      final blob = html.Blob([json], 'application/json');
      final safeFilename =
          entry.key.replaceAll(RegExp(r"https?://"), "").replaceAll("/", "_");
      final filename =
          'scan_${safeFilename}_${DateTime.now().toIso8601String()}.json';
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(blobUrl);
    }
  }

  void _navigateToDashboard() {
    final dashboardData = _scanResults.entries
        .where((entry) => entry.value['status'] == 'Success')
        .expand((entry) =>
            ((entry.value['data'] as Map<String, dynamic>)['results'] as List)
                .where((r) => r['vulnerable'] == true)
                .map((r) => r['type'] as String))
        .fold<Map<String, int>>({}, (acc, type) {
          acc[type] = (acc[type] ?? 0) + 1;
          return acc;
        })
        .entries
        .map((e) => {'type': e.key, 'count': e.value})
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThreatDashboard(vulnerabilityData: dashboardData),
      ),
    );
  }

  Widget _buildResultCard(String url, dynamic result) {
    final status = result['status'];
    final color = switch (status) {
      'Queued' => Colors.grey.shade200,
      'Error' => Colors.red.shade100,
      'Success' => Colors.green.shade50,
      _ => Colors.yellow.shade100,
    };

    return Card(
      color: color,
      child: ExpansionTile(
        leading: Icon(
          switch (status) {
            'Success' => Icons.check_circle,
            'Error' => Icons.cancel,
            _ => Icons.hourglass_top,
          },
          color: switch (status) {
            'Success' => Colors.green,
            'Error' => Colors.red,
            _ => Colors.orange,
          },
        ),
        title: Text('$url [$status]',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          if (status == 'Success')
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SelectableText(
                const JsonEncoder.withIndent('  ')
                    .convert(result['data']),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            )
          else if (result['message'] != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(result['message']),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultWidgets = _scanResults.entries
        .map((entry) => _buildResultCard(entry.key, entry.value))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('AWATP Web Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _urlController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter one or more target URLs (one per line)',
              ),
            ),
            const SizedBox(height: 12),
            const Text('Select Scan Modules:'),
            ..._scanModules.entries.map((e) => CheckboxListTile(
                  title: Text(e.key),
                  value: e.value,
                  onChanged: (val) {
                    setState(() {
                      _scanModules[e.key] = val ?? false;
                    });
                  },
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _scanning ? null : _runScan,
                  child: const Text('Run Scan'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _scanResults.isEmpty ? null : _navigateToDashboard,
                  child: const Text('View Dashboard'),
                ),
                const Spacer(),
                if (_scanResults.isNotEmpty)
                  TextButton.icon(
                    onPressed: _downloadAllAsZip,
                    icon: const Icon(Icons.download),
                    label: const Text('Download JSON'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...resultWidgets,
          ],
        ),
      ),
    );
  }
}

