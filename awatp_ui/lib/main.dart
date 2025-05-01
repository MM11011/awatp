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
  String result = "";

  Future<void> runScan() async {
    final selectedModules =
        modules.entries.where((e) => e.value).map((e) => e.key).toList();

    final response = await http.post(
      Uri.parse('http://localhost:5000/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "url": urlController.text,
        "modules": selectedModules,
      }),
    );

    setState(() {
      result = response.statusCode == 200
          ? const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body))
          : "Error: ${response.statusCode}";
    });
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
              decoration: InputDecoration(labelText: "Enter Target URL"),
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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: runScan,
              child: Text("Run Scan"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
