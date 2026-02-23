import 'package:flutter/material.dart';
import '../widgets/surplus_shortage_map.dart';

class SurplusShortageMapPage extends StatelessWidget {
  const SurplusShortageMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surplus/Shortage Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: Colors.green, label: 'Surplus', value: '+15%'),
                _LegendItem(color: Colors.red, label: 'Shortage', value: '-8%'),
                _LegendItem(color: Colors.orange, label: 'Balanced', value: '±3%'),
              ],
            ),
          ),
          const Expanded(child: SurplusShortageMap()),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
