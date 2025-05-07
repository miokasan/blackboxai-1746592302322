import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/bluetooth_service.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Get.find<BluetoothService>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => bluetoothService.startDiscovery(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (bluetoothService.devices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        bluetoothService.connectionStatus.value == 'Scanning...'
                            ? 'Searching for devices...'
                            : 'No devices found',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: bluetoothService.devices.length,
                itemBuilder: (context, index) {
                  final device = bluetoothService.devices[index];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.name),
                    subtitle: Text(device.address),
                    trailing: device.isConnected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined),
                    onTap: () async {
                      await bluetoothService.connectToDevice(device.address);
                      Get.back();
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
