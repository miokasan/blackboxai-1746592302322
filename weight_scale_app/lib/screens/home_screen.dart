import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../widgets/weight_display.dart';
import '../widgets/device_list.dart';
import '../services/bluetooth_service.dart';
import '../services/sheets_service.dart';
import '../models/weight_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final bluetoothService = Get.put(BluetoothService());
    final sheetsService = Get.put(SheetsService());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weight Scale'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Get.to(() => const SettingsScreen()),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Weight Monitor'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WeightMonitorTab(),
            const HistoryScreen(),
          ],
        ),
      ),
    );
  }
}

class WeightMonitorTab extends StatelessWidget {
  WeightMonitorTab({Key? key}) : super(key: key);

  final bluetoothService = Get.find<BluetoothService>();
  final sheetsService = Get.find<SheetsService>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const WeightDisplay(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const DeviceList(),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Scan Bluetooth'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() {
              final isConnected = bluetoothService.isConnected.value;
              final weight = bluetoothService.currentWeight.value;
              
              return ElevatedButton.icon(
                onPressed: isConnected && weight > 0
                    ? () async {
                        final data = WeightData(
                          weight: weight,
                          timestamp: DateTime.now(),
                        );
                        
                        final success = await sheetsService.sendData(data);
                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Data sent to Google Sheets',
                            backgroundColor: Colors.green.withOpacity(0.1),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.send),
                label: const Text('Send to Sheets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.1),
                  disabledForegroundColor: Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final recentHistory = sheetsService.getRecentHistory();
                      
                      if (recentHistory.isEmpty) {
                        return const Center(
                          child: Text(
                            'No recent data',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        children: recentHistory.map((data) => ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text('${data.weight.toStringAsFixed(2)} kg'),
                          subtitle: Text(
                            data.timestamp.toString().split('.')[0],
                            style: const TextStyle(fontSize: 12),
                          ),
                        )).toList(),
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
