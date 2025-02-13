import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/telemetry_provider.dart';
import '../components/telemetry_chart.dart'; // Importe o componente

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TelemetryProvider>(context, listen: false).startFetching();
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = Provider.of<TelemetryProvider>(context);
    final sizeOf = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dados de Telemetria'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 8,
          ),
          child: SizedBox(
            height: sizeOf.height * .8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gráfico de Velocidade
                TelemetryChart(
                  title: 'Velocidade (km/h)',
                  values: telemetry.speedHistory,
                  color: Colors.blue,
                  sizeOf: sizeOf,
                ),
                // Gráfico de Temperatura
                TelemetryChart(
                  title: 'Temperatura (°C)',
                  values: telemetry.tempHistory,
                  color: Colors.red,
                  sizeOf: sizeOf,
                ),
                // Gráfico de RPM
                TelemetryChart(
                  title: 'RPM',
                  values: telemetry.rpmHistory,
                  color: Colors.green,
                  sizeOf: sizeOf,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await telemetry.toggleSaving();
                        if (result.isNotEmpty) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        }
                      },
                      child: Text(
                        telemetry.isSaving ? 'Baixar Dados' : 'Salvar Dados',
                      ),
                    ),
                    if (telemetry.isSaving)
                      ElevatedButton(
                        onPressed: telemetry.cancelSaving,
                        child: const Text('Cancelar Salvamento'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: telemetry.togglePause,
        backgroundColor: Colors.red,
        child: Icon(
          telemetry.isPaused ? Icons.play_arrow : Icons.pause,
          color: Colors.white,
        ),
      ),
    );
  }
}
