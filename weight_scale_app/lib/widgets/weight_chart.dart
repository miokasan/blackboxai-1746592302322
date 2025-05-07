import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../services/sheets_service.dart';
import '../models/weight_data.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sheetsService = Get.find<SheetsService>();

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                final history = sheetsService.sentHistory;
                
                if (history.isEmpty) {
                  return const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= history.length) return const Text('');
                            final date = history[value.toInt()].timestamp;
                            return Text(
                              '${date.hour}:${date.minute}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: history.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.weight,
                          );
                        }).toList(),
                        isCurved: true,
                        color: Colors.blue,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
