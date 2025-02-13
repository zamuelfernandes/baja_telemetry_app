// lib/components/telemetry_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TelemetryChart extends StatefulWidget {
  final String title;
  final List<double> values;
  final Color color;
  final Size sizeOf;

  const TelemetryChart({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    required this.sizeOf,
  });

  @override
  State<TelemetryChart> createState() => _TelemetryChartState();
}

class _TelemetryChartState extends State<TelemetryChart> {
  bool isTemp = false;
  bool isRPM = false;

  @override
  void initState() {
    if (widget.title == 'Temperatura (°C)') {
      isTemp = true;
    } else if (widget.title == 'RPM') {
      isRPM = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      children: [
        Row(
          children: [
            Text(
              '${widget.title}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Text(
              ' ${widget.values.isNotEmpty ? widget.values.last : 0}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isTemp
                    ? widget.values.isNotEmpty && widget.values.last > 85
                        ? Colors.red[800]
                        : Colors.green[800]
                    : isRPM
                        ? widget.values.isNotEmpty && widget.values.last > 3900
                            ? Colors.red[800]
                            : widget.values.isNotEmpty &&
                                    widget.values.last > 2500
                                ? Colors.yellow[800]
                                : Colors.green[800]
                        : Colors.brown,
              ),
            ),
          ],
        ),
        SizedBox(
          height: widget.sizeOf.height * .15,
          child: LineChart(
            curve: Curves.linear,
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    // getTitlesWidget: (value, meta) {
                    //   return Text(
                    //     value.toString(),
                    //     style: const TextStyle(fontSize: 12),
                    //   );
                    // },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()} s',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 20, // Eixo X fixo de 0 a 20 segundos
              minY: 0,
              maxY: widget.values.isNotEmpty
                  ? widget.values.reduce((a, b) => a > b ? a : b) + 2
                  : 10, // Ajuste dinâmico do eixo Y
              lineBarsData: [
                LineChartBarData(
                  isStepLineChart: true,
                  spots: widget.values.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: false,
                  color: widget.color,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: widget.color.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
