import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class TelemetryProvider with ChangeNotifier {
  String _ip = '';

  final List<double> _speedHistory = [];
  final List<double> _tempHistory = [];
  final List<double> _rpmHistory = [];
  bool _isPaused = false;

  bool _isSaving = false;
  final List<Map<String, double>> _savedData = [];

  List<double> get speedHistory => _speedHistory;
  List<double> get tempHistory => _tempHistory;
  List<double> get rpmHistory => _rpmHistory;
  bool get isPaused => _isPaused;
  bool get isSaving => _isSaving;
  List<Map<String, dynamic>> get savedData => _savedData;

  void setIp(String ip) {
    _ip = ip;
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  Future<bool> _requestPemission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      final re = await Permission.manageExternalStorage.request();
      if (re.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        final result = await permission.request();
        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future<String> toggleSaving() async {
    // Verifica e solicita permissão de armazenamento
    final status = await _requestPemission(Permission.storage);

    try {
      if (status) {
        _isSaving = !_isSaving;
        if (!_isSaving) {
          final notify = await _generateCsv();

          switch (notify) {
            case null:
              return 'Dados vazios para salvamento';
            case false:
              return 'Erro ao salvar dados';
            case true:
              return 'Dados salvos em Downloads!';
          }
        }
        return '';
      } else {
        debugPrint('Permissão de armazenamento negada');
        return 'Permissão de armazenamento negada';
      }
    } catch (e) {
      debugPrint('ERRO EM TOGGLESAVING CSV:\n${e.toString()}');
      return 'Erro ao salvar dados';
    } finally {
      notifyListeners();
    }
  }

  void cancelSaving() {
    _savedData.clear();
    _isSaving = false;
    notifyListeners();
  }

  Future<bool?> _generateCsv() async {
    if (_savedData.isEmpty) return null;

    try {
      // Obtém o diretório de downloads público
      final directory = Directory('/storage/emulated/0/Download/TelemetryData');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}/telemetry_data.csv');

      final csvData = StringBuffer();
      csvData.writeln('Timestamp,Speed (km/h),Temp (°C),RPM');

      // Formata o Timestamp
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss'); // Formato desejado

      for (var data in _savedData) {
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(data['timestamp']!.toInt());
        final formattedTimestamp =
            dateFormat.format(timestamp); // Formata o Timestamp

        csvData.writeln(
            '$formattedTimestamp,${data['speed']},${data['temp']},${data['rpm']}');
      }

      await file.writeAsString(csvData.toString());
      debugPrint('Arquivo CSV salvo em: ${file.path}');

      _savedData.clear();
      return true;
    } catch (e) {
      debugPrint('ERRO EM SALVAR CSV:\n${e.toString()}');
      return false;
    } finally {
      notifyListeners();
    }
  }

  void startFetching() {
    Future.delayed(Duration.zero, () async {
      while (true) {
        await fetchData();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    });
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

    if (_isSaving) {
      _savedData.add({
        'speed': speed,
        'temp': temp,
        'rpm': rpm,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toDouble(),
      });
    }

    notifyListeners();
  }

  void _updateHistory(List<double> history, double newValue) {
    history.add(newValue);
    if (history.length > 20) {
      history.removeAt(0);
    }
  }

}
