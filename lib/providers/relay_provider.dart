import 'package:asepe_homes/models/relay_switch_on_off.dart';
import 'package:asepe_homes/providers/power_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RelayProvider extends ChangeNotifier {
  RelaySwitchOnOff _relaySwitches = RelaySwitchOnOff(
    relay1: RelayState.off,
    relay2: RelayState.off,
    relay3: RelayState.off,
    id: null,
  );

  bool _isLoading = false;
  String? _lastError;

  RelaySwitchOnOff get relaySwitches => _relaySwitches;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  bool get relay1 => _relaySwitches.relay1 == RelayState.on;
  bool get relay2 => _relaySwitches.relay2 == RelayState.on;
  bool get relay3 => _relaySwitches.relay3 == RelayState.on;

  final String _baseUrl = baseUrl;

  Future<void> updateRelay(int relayNumber, bool value) async {
    if (_isLoading) return;
    _isLoading = true;
    _clearError();
    notifyListeners();

    final previousState = RelaySwitchOnOff(
      relay1: _relaySwitches.relay1,
      relay2: _relaySwitches.relay2,
      relay3: _relaySwitches.relay3,
      id: _relaySwitches.id,
    );

    try {
      _updateLocalState(relayNumber, value);

      final response = await _sendRelayUpdateRequest();

      if (response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (responseData is Map<String, dynamic>) {
            _relaySwitches = RelaySwitchOnOff.fromJson(responseData);
          }
        } catch (e) {
          debugPrint('Error parsing server response: $e');
          _setError('Failed to parse server response');
        }
      } else {
        _relaySwitches = previousState;
        _setError(
          'Failed to update Relay $relayNumber: Server error ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error updating relay: $e');
      _relaySwitches = previousState;
      _setError(_getReadableErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMultipleRelays({
    bool? relay1,
    bool? relay2,
    bool? relay3,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _clearError();
    notifyListeners();

    final previousState = RelaySwitchOnOff(
      relay1: _relaySwitches.relay1,
      relay2: _relaySwitches.relay2,
      relay3: _relaySwitches.relay3,
      id: _relaySwitches.id,
    );

    try {
      _relaySwitches = RelaySwitchOnOff(
        relay1:
            relay1 != null
                ? (relay1 ? RelayState.on : RelayState.off)
                : _relaySwitches.relay1,
        relay2:
            relay2 != null
                ? (relay2 ? RelayState.on : RelayState.off)
                : _relaySwitches.relay2,
        relay3:
            relay3 != null
                ? (relay3 ? RelayState.on : RelayState.off)
                : _relaySwitches.relay3,
        id: _relaySwitches.id,
      );

      final response = await _sendRelayUpdateRequest();

      if (response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (responseData is Map<String, dynamic>) {
            _relaySwitches = RelaySwitchOnOff.fromJson(responseData);
          }
        } catch (e) {
          debugPrint('Error parsing server response: $e');
          _setError('Failed to parse server response');
        }
      } else {
        _relaySwitches = previousState;
        _setError(
          'Failed to reset relays: Server error ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error updating multiple relays: $e');
      _relaySwitches = previousState;
      _setError(_getReadableErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _lastError = error;
  }

  void _clearError() {
    _lastError = null;
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  String _getReadableErrorMessage(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout - please check your network';
    } else if (error.toString().contains('SocketException')) {
      return 'Network connection failed - please check your internet';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data received from server';
    } else {
      return 'An unexpected error occurred';
    }
  }

  Future<void> fetchRelayStates() async {
    if (_isLoading) return;

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/RelayOptions'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        const targetId = "689ee8ad7b24a69374926f3a";
        final targetItem = responseData.firstWhere(
          (item) => item['_id'] == targetId,
          orElse: () => null,
        );

        if (targetItem != null) {
          _relaySwitches = RelaySwitchOnOff.fromJson(targetItem);
        } else {
          _setError('Device configuration not found');
        }
      } else {
        _setError(
          'Failed to fetch relay states: Server error ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching relay states: $e');
      _setError(_getReadableErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetAllRelays() async {
    await updateMultipleRelays(relay1: false, relay2: false, relay3: false);
  }

  void _updateLocalState(int relayNumber, bool value) {
    final newState = value ? RelayState.on : RelayState.off;

    switch (relayNumber) {
      case 1:
        _relaySwitches = RelaySwitchOnOff(
          relay1: newState,
          relay2: _relaySwitches.relay2,
          relay3: _relaySwitches.relay3,
          id: _relaySwitches.id,
        );
        break;
      case 2:
        _relaySwitches = RelaySwitchOnOff(
          relay1: _relaySwitches.relay1,
          relay2: newState,
          relay3: _relaySwitches.relay3,
          id: _relaySwitches.id,
        );
        break;
      case 3:
        _relaySwitches = RelaySwitchOnOff(
          relay1: _relaySwitches.relay1,
          relay2: _relaySwitches.relay2,
          relay3: newState,
          id: _relaySwitches.id,
        );
        break;
    }
  }

  Future<http.Response> _sendRelayUpdateRequest() async {
    final requestBody = _relaySwitches.toJson();

    debugPrint('Sending relay update: $requestBody');

    return await http.put(
      Uri.parse('$_baseUrl/RelayControl/689ee8ad7b24a69374926f3a/update'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(requestBody),
    );
  }
}

extension RelayStateExtension on RelayState {
  bool get isOn => this == RelayState.on;
  bool get isOff => this == RelayState.off;

  String get displayText => isOn ? 'ON' : 'OFF';
}
