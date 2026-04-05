// lib/features/analytics/presentation/widgets/chart_widget.dart
import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const ChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final maxValue = data.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final entries = data.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth /
            (entries.length * 2); // spacing

        return SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.map((e) {
              final ratio = e.value / maxValue;
              final height = ratio * 160;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: height,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7BA53D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
