import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ThreatDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> vulnerabilityData;

  const ThreatDashboard({super.key, required this.vulnerabilityData});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = vulnerabilityData.map((data) {
      final type = data['type'] as String;
      final count = (data['count'] as int).toDouble();
      final color = _colorForType(type);

      return PieChartSectionData(
        color: color,
        value: count,
        title: '$type\n${count.toInt()}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Threat Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: vulnerabilityData.isEmpty
            ? const Center(child: Text('No threats detected.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Vulnerability Distribution',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Raw Data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: vulnerabilityData.map((e) {
                        return ListTile(
                          leading: const Icon(Icons.security),
                          title: Text('${e['type']}'),
                          trailing: Text('${e['count']} found'),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'sqli':
        return Colors.redAccent;
      case 'xss':
        return Colors.orangeAccent;
      case 'ssti':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }
}
