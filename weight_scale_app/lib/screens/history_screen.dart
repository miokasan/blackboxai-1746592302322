import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/weight_chart.dart';
import '../services/sheets_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sheetsService = Get.find<SheetsService>();

    return SingleChildScrollView(
      child: Column(
        children: [
          const WeightChart(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sent Data History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (sheetsService.sentHistory.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No history available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sheetsService.sentHistory.length,
                        itemBuilder: (context, index) {
                          final data = sheetsService.sentHistory[index];
                          return ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text('${data.weight.toStringAsFixed(2)} kg'),
                            subtitle: Text(
                              data.timestamp.toString().split('.')[0],
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // Implement share functionality if needed
                                Get.snackbar(
                                  'Share',
                                  'Weight: ${data.weight}kg\nTime: ${data.timestamp}',
                                  duration: const Duration(seconds: 2),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
