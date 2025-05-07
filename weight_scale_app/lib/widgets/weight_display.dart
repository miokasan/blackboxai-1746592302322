import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/bluetooth_service.dart';

class WeightDisplay extends StatelessWidget {
  const WeightDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Get.find<BluetoothService>();

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connection Status
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  bluetoothService.isConnected.value
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: bluetoothService.isConnected.value
                      ? Colors.blue
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  bluetoothService.connectionStatus.value,
                  style: TextStyle(
                    color: bluetoothService.isConnected.value
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ],
            )),
            
            const SizedBox(height: 24),
            
            // Weight Display
            Obx(() => Text(
              '${bluetoothService.currentWeight.value.toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            )),
            
            const SizedBox(height: 16),
            
            // Last Updated Time
            Obx(() => Text(
              'Last Updated: ${DateTime.now().toString().split('.')[0]}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
