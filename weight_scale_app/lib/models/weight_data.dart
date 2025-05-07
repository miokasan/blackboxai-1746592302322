class WeightData {
  final double weight;
  final DateTime timestamp;
  final bool isSentToSheets;

  WeightData({
    required this.weight,
    required this.timestamp,
    this.isSentToSheets = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'isSentToSheets': isSentToSheets,
    };
  }

  factory WeightData.fromJson(Map<String, dynamic> json) {
    return WeightData(
      weight: json['weight'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      isSentToSheets: json['isSentToSheets'] ?? false,
    );
  }
}

class BluetoothDevice {
  final String name;
  final String address;
  final bool isConnected;

  BluetoothDevice({
    required this.name,
    required this.address,
    this.isConnected = false,
  });
}
