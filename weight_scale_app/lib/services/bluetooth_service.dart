import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import '../models/weight_data.dart';

class BluetoothService extends GetxController {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  final RxDouble currentWeight = 0.0.obs;
  final RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  StreamSubscription<dynamic>? _dataStreamSubscription;

  Future<void> startDiscovery() async {
    devices.clear();
    connectionStatus.value = 'Scanning...';

    try {
      _discoveryStreamSubscription?.cancel();
      _discoveryStreamSubscription = _bluetooth.startDiscovery().listen(
        (result) {
          final device = BluetoothDevice(
            name: result.device.name ?? 'Unknown',
            address: result.device.address,
          );
          if (!devices.any((d) => d.address == device.address)) {
            devices.add(device);
          }
        },
        onDone: () {
          connectionStatus.value = 'Scan Complete';
        },
        onError: (error) {
          connectionStatus.value = 'Error: $error';
        }
      );
    } catch (e) {
      connectionStatus.value = 'Error: $e';
    }
  }

  Future<void> connectToDevice(String address) async {
    try {
      connectionStatus.value = 'Connecting...';
      _connection = await BluetoothConnection.toAddress(address);
      
      if (_connection != null) {
        isConnected.value = true;
        connectionStatus.value = 'Connected';
        
        _dataStreamSubscription = _connection!.input?.listen(
          (data) {
            final String receivedData = ascii.decode(data);
            try {
              final double weight = double.parse(receivedData);
              currentWeight.value = weight;
            } catch (e) {
              print('Error parsing weight data: $e');
            }
          },
          onError: (error) {
            print('Error receiving data: $error');
            disconnect();
          },
          onDone: () {
            disconnect();
          },
        );
      }
    } catch (e) {
      connectionStatus.value = 'Connection failed: $e';
      isConnected.value = false;
    }
  }

  Future<void> disconnect() async {
    try {
      _dataStreamSubscription?.cancel();
      await _connection?.close();
      _connection = null;
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      currentWeight.value = 0.0;
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  @override
  void onClose() {
    _discoveryStreamSubscription?.cancel();
    _dataStreamSubscription?.cancel();
    _connection?.close();
    super.onClose();
  }
}
