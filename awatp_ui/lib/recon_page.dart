import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReconPage extends StatefulWidget {
  const ReconPage({super.key});

  @override
  _ReconPageState createState() => _ReconPageState();
}

class _ReconPageState extends State<ReconPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _reconResults = {};

  Future<void> _performRecon() async {
    final urls = _urlController.text
        .split(',')
        .map((e) => e.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (urls.isEmpty) return;

    setState(() {
      _isLoading = true;
      _reconResults.clear();
    });

    final response = await http.post(
      Uri.parse('http://localhost:5000/recon'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'urls': urls}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _reconResults = jsonDecode(response.body);
      });
    } else {
      setState(() {
        _reconResults = {
          'error': 'Failed to fetch recon data. (${response.statusCode})'
        };
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recon Module')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter URLs separated by commas'),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'example.com, httpbin.org',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performRecon,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Run Recon'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _reconResults.isEmpty
                  ? const Text('No recon data yet.')
                  : ListView(
                      children: _reconResults.entries.map((entry) {
                        return ListTile(
                          leading: const Icon(Icons.search),
                          title: Text(entry.key),
                          subtitle: Text(entry.value.toString()),
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
