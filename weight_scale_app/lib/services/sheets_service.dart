import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences.dart';
import '../models/weight_data.dart';

class SheetsService extends GetxController {
  final RxString apiUrl = ''.obs;
  final RxBool isSending = false.obs;
  final RxList<WeightData> sentHistory = <WeightData>[].obs;
  
  static const String API_URL_KEY = 'sheets_api_url';
  late SharedPreferences _prefs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    loadApiUrl();
  }

  void loadApiUrl() {
    apiUrl.value = _prefs.getString(API_URL_KEY) ?? '';
  }

  Future<void> saveApiUrl(String url) async {
    await _prefs.setString(API_URL_KEY, url);
    apiUrl.value = url;
  }

  Future<bool> testConnection() async {
    if (apiUrl.value.isEmpty) {
      Get.snackbar('Error', 'Please set the API URL first');
      return false;
    }

    try {
      final response = await http.get(Uri.parse(apiUrl.value));
      return response.statusCode == 200;
    } catch (e) {
      Get.snackbar('Error', 'Connection test failed: $e');
      return false;
    }
  }

  Future<bool> sendData(WeightData data) async {
    if (apiUrl.value.isEmpty) {
      Get.snackbar('Error', 'Please set the API URL first');
      return false;
    }

    isSending.value = true;

    try {
      final response = await http.post(
        Uri.parse(apiUrl.value),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'timestamp': data.timestamp.toIso8601String(),
          'weight': data.weight,
        }),
      );

      if (response.statusCode == 200) {
        final sentData = WeightData(
          weight: data.weight,
          timestamp: data.timestamp,
          isSentToSheets: true,
        );
        sentHistory.insert(0, sentData);
        Get.snackbar('Success', 'Data sent to Google Sheets');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to send data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send data: $e');
      return false;
    } finally {
      isSending.value = false;
    }
  }

  List<WeightData> getRecentHistory([int limit = 5]) {
    return sentHistory.take(limit).toList();
  }

  void clearHistory() {
    sentHistory.clear();
  }
}
