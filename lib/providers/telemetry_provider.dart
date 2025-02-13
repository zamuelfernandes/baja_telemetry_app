import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelemetryProvider with ChangeNotifier {
  String _ip = '';
  List<double> _speedHistory = [];
  List<double> _tempHistory = [];
  List<double> _rpmHistory = [];
  bool _isPaused = false;

  List<double> get speedHistory => _speedHistory;
  List<double> get tempHistory => _tempHistory;
  List<double> get rpmHistory => _rpmHistory;
  bool get isPaused => _isPaused;

  void setIp(String ip) {
    _ip = ip;
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  Future<void> fetchData() async {
    if (_isPaused) return;

    final url = 'http://$_ip/metrics';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _parseData(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados: $e');
    }
  }

  void _parseData(String data) {
    final lines = data.split('\n');
    double speed = 0.0, temp = 0.0, rpm = 0.0;

    for (var line in lines) {
      if (line.startsWith('telemetry_speed')) {
        speed = double.parse(line.split(' ')[1]);
      } else if (line.startsWith('telemetry_temp')) {
        temp = double.parse(line.split(' ')[1]);
      } else if (line.startsWith('telemetry_rpm')) {
        rpm = double.parse(line.split(' ')[1]);
      }
    }

    _updateHistory(_speedHistory, speed);
    _updateHistory(_tempHistory, temp);
    _updateHistory(_rpmHistory, rpm);

    notifyListeners();
  }

  void _updateHistory(List<double> history, double newValue) {
    history.add(newValue);
    if (history.length > 20) {
      history.removeAt(0);
    }
  }

  void startFetching() {
    Future.delayed(Duration.zero, () async {
      while (true) {
        await fetchData();
        await Future.delayed(const Duration(seconds: 1));
      }
    });
  }
}
