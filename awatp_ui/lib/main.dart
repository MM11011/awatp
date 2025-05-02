import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(AWATPApp());

class AWATPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWATP Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScanPage(),
    );
  }
}

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController urlController = TextEditingController();
  final Map<String, bool> modules = {
    "sqli": false,
    "xss": false,
    "ssti": false,
  };
  List<Map<String, dynamic>> scanResults = [];

  Future<void> runScan() async {
    final rawUrls = urlController.text.split('\n');
    final urls = rawUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final selectedModules =
        modules.entries.where((e) => e.value).map((e) => e.key).toList();

    setState(() {
      scanResults.clear();
    });

    for (final url in urls) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.101.245:5000/scan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "url": url,
            "modules": selectedModules,
          }),
        );

        final parsed = jsonDecode(response.body);
        setState(() {
          scanResults.add({
            "url": url,
            "status": response.statusCode,
            "data": parsed,
          });
        });
      } catch (e) {
        setState(() {
          scanResults.add({
            "url": url,
            "status": 0,
            "error": e.toString(),
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AWATP Web Scanner")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter one or more target URLs (one per line)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: modules.keys.map((module) {
                return CheckboxListTile(
                  title: Text(module.toUpperCase()),
                  value: modules[module],
                  onChanged: (val) {
                    setState(() {
                      modules[module] = val!;
                    });
                  },
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: runScan,
              child: Text("Run Scan"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final item = scanResults[index];
                  final url = item['url'];
                  final status = item['status'];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: item.containsKey('error')
                          ? Text("❌ $url\nError: ${item['error']}")
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("✅ $url [Status: $status]", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text(
                                  const JsonEncoder.withIndent('  ').convert(item['data']),
                                  style: TextStyle(fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
