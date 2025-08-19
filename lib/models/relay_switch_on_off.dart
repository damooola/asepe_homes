enum RelayState { off, on }

class RelaySwitchOnOff {
  final RelayState relay1;
  final RelayState relay2;
  final RelayState relay3;
  final String? id;

  RelaySwitchOnOff({
    required this.relay1,
    required this.relay2,
    required this.relay3,
    required this.id,
  });

  factory RelaySwitchOnOff.fromJson(Map<String, dynamic> json) {
    return RelaySwitchOnOff(
      relay1: _intToRelayState(json['relay1']),
      relay2: _intToRelayState(json['relay2']),
      relay3: _intToRelayState(json['relay3']),
      id: json['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relay1': _relayStateToInt(relay1),
      'relay2': _relayStateToInt(relay2),
      'relay3': _relayStateToInt(relay3),
    };
  }

  static RelayState _intToRelayState(dynamic value) {
    final intVal = (value as num).toInt();
    if (intVal == 1) return RelayState.on;
    return RelayState.off;
  }

  static int _relayStateToInt(RelayState state) {
    return state == RelayState.on ? 1 : 0;
  }
}
