import 'dart:async';
import 'dart:convert';

import 'package:asepe_homes/models/power.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://smartmeter-project.onrender.com/api';

class PowerProvider extends ChangeNotifier {
  PowerData? _latestPowerData;
  List<PowerData> _powerHistory = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  Timer? _timer;

  PowerData? get latestPowerData => _latestPowerData;
  List<PowerData> get powerHistory => _powerHistory;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;

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

  Future<void> fetchPowerHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/MetricList'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _powerHistory = data.map((item) => PowerData.fromJson(item)).toList();
        _powerHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (_powerHistory.isNotEmpty && _latestPowerData == null) {
          _latestPowerData = _powerHistory.first;
        }
      } else {
        throw Exception('Failed to fetch power history');
      }
    } catch (e) {
      debugPrint('Error fetching power history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  List<PowerData> getPowerHistoryByTimeRange(Duration timeRange) {
    final cutoffDate = DateTime.now().subtract(timeRange);
    return _powerHistory
        .where((data) => data.createdAt.isAfter(cutoffDate))
        .toList();
  }

  double getAveragePower(int powerLine, Duration timeRange) {
    final filteredData = getPowerHistoryByTimeRange(timeRange);
    if (filteredData.isEmpty) return 0;

    double total = 0;
    for (var data in filteredData) {
      switch (powerLine) {
        case 1:
          total += data.power1;
          break;
        case 2:
          total += data.power2;
          break;
        case 3:
          total += data.power3;
          break;
      }
    }
    return total / filteredData.length;
  }

  double getPeakPower(int powerLine, Duration timeRange) {
    final filteredData = getPowerHistoryByTimeRange(timeRange);
    if (filteredData.isEmpty) return 0;

    double peak = 0;
    for (var data in filteredData) {
      double power = 0;
      switch (powerLine) {
        case 1:
          power = data.power1;
          break;
        case 2:
          power = data.power2;
          break;
        case 3:
          power = data.power3;
          break;
      }
      if (power > peak) peak = power;
    }
    return peak;
  }

  double getTotalEnergyConsumption(Duration timeRange) {
    final filteredData = getPowerHistoryByTimeRange(timeRange);
    if (filteredData.length < 2) return 0;

    double totalEnergy = 0;

    for (int i = 0; i < filteredData.length - 1; i++) {
      final current = filteredData[i];
      final next = filteredData[i + 1];

      final timeDiffHours =
          current.createdAt.difference(next.createdAt).inMinutes / 60.0;

      final avgPower =
          (current.power1 +
              current.power2 +
              current.power3 +
              next.power1 +
              next.power2 +
              next.power3) /
          6;

      totalEnergy += (avgPower * timeDiffHours) / 1000;
    }

    return totalEnergy;
  }

  void clearHistory() {
    _powerHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
