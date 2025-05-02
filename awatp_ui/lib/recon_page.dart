import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReconPage extends StatefulWidget {
  const ReconPage({super.key});

  @override
  State<ReconPage> createState() => _ReconPageState();
}

class _ReconPageState extends State<ReconPage> {
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic> _reconResults = {};
  bool _isLoading = false;

  Future<void> _runRecon() async {
    final urls = _urlController.text
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (urls.isEmpty) return;

    setState(() {
      _isLoading = true;
      _reconResults.clear();
    });

    try {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recon failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recon Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter domains (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _runRecon,
              child: const Text('Run Recon'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: _reconResults.entries.map((entry) {
                        final ip = entry.value['resolved_ip'] ?? 'Unknown';
                        return ListTile(
                          leading: const Icon(Icons.public),
                          title: Text(entry.key),
                          subtitle: Text('Resolved IP: $ip'),
                        );
                      }).toList(),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
