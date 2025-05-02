import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AWATP Web Scanner',
      home: ScanPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _urlController = TextEditingController();
  final List<String> _selectedModules = [];
  final Map<String, dynamic> _scanResults = {};
  final String apiUrl = 'http://192.168.101.245:5000/scan'; // replace if needed

  Future<void> _runScan() async {
    final urls = _urlController.text
        .split('\n')
        .map((e) => e.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    setState(() {
      for (var url in urls) {
        _scanResults[url] = {'status': 'queued'};
      }
    });

    for (final url in urls) {
      setState(() {
        _scanResults[url]['status'] = 'scanning';
      });

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'url': url,
            'modules': _selectedModules,
          }),
        );

        final data = jsonDecode(response.body);
        setState(() {
          _scanResults[url] = {
            'status': 'done',
            'result': data,
            'json': const JsonEncoder.withIndent('  ').convert(data)
          };
        });
      } catch (e) {
        setState(() {
          _scanResults[url] = {
            'status': 'error',
            'error': e.toString(),
          };
        });
      }
    }
  }

  void _downloadAllAsZip() {
    html.AnchorElement(
      href: 'http://${apiUrl.split('/')[2]}/download',
    )
      ..target = '_blank'
      ..download = 'scan_results.zip'
      ..click();
  }

  Widget _buildCheckbox(String label, String value) {
    return CheckboxListTile(
      title: Text(label),
      value: _selectedModules.contains(value),
      onChanged: (selected) {
        setState(() {
          selected!
              ? _selectedModules.add(value)
              : _selectedModules.remove(value);
        });
      },
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildResultCard(String url, dynamic result) {
    if (result['status'] == 'scanning') {
      return ListTile(
        leading: const Text('⏳'),
        title: Text('$url [Scanning...]'),
      );
    } else if (result['status'] == 'queued') {
      return ListTile(
        leading: const Icon(Icons.search),
        title: Text('$url [Queued]'),
      );
    } else if (result['status'] == 'error') {
      return Card(
        color: Colors.red[100],
        child: ListTile(
          leading: const Icon(Icons.cancel, color: Colors.red),
          title: Text(
            '$url [Error]',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(result['error']),
        ),
      );
    } else {
      return Card(
        color: Colors.green[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text('$url [Status: ${result['result']['fingerprint']['Status Code'] ?? 'N/A'}]'),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download JSON',
                onPressed: () {
                  final bytes = utf8.encode(result['json']);
                  final blob = html.Blob([bytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor = html.AnchorElement(href: url)
                    ..download = 'scan_result_${Uri.parse(url).host}.json'
                    ..click();
                  html.Url.revokeObjectUrl(url);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(result['json'] ?? 'No data'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AWATP Web Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter one or more target URLs (one per line)',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            _buildCheckbox('SQLI', 'sqli'),
            _buildCheckbox('XSS', 'xss'),
            _buildCheckbox('SSTI', 'ssti'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _runScan,
              child: const Text('Run Scan'),
            ),
            if (_scanResults.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _downloadAllAsZip,
                  icon: const Icon(Icons.download),
                  label: const Text('Download All as ZIP'),
                ),
              ),
            const SizedBox(height: 10),
            ..._scanResults.entries
                .map((entry) => _buildResultCard(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }
}

