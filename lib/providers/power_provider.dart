import 'dart:async';
import 'dart:convert';

import 'package:asepe_homes/models/power.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://smartmeter-project.onrender.com/api';

class PowerProvider extends ChangeNotifier {
  PowerData? _latestPowerData;
  bool _isLoading = false;
  Timer? _timer;

  PowerData? get latestPowerData => _latestPowerData;
  bool get isLoading => _isLoading;

  PowerProvider() {
    fetchLatestPowerData();
    startPeriodicFetch();
  }

  void startPeriodicFetch() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetchLatestPowerData();
    });
  }

  Future<void> fetchLatestPowerData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/MetricList'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          data.sort(
            (a, b) => DateTime.parse(
              b['createdAt'],
            ).compareTo(DateTime.parse(a['createdAt'])),
          );
          _latestPowerData = PowerData.fromJson(data.first);
        }
      } else {
        throw Exception('Failed to fetch power data');
      }
    } catch (e) {
      debugPrint('Error fetching power data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
