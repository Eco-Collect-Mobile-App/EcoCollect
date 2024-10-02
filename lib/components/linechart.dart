import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Define a placeholder WasteData class if it's not already defined
class WasteData {
  final String name;
  final String nic;
  final int organic;
  final int plastic;
  final int recyclable;
  final int other;

  WasteData({
    required this.name,
    required this.nic,
    required this.organic,
    required this.plastic,
    required this.recyclable,
    required this.other,
  });
}

class WasteLineChart extends StatelessWidget {
  final List<WasteData> wasteDataList;

  WasteLineChart({required this.wasteDataList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 360,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  lineTouchData: lineTouchData,
                  gridData: FlGridData(show: false),
                  titlesData: titlesData,
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.blue.withOpacity(0.2), width: 4),
                      left: BorderSide(color: Colors.transparent),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  lineBarsData: lineBarsData,
                  minX: 0,
                  maxX: wasteDataList.length.toDouble(),
                  minY: 0,
                  maxY: getMaxY(),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LegendEntry(color: Colors.green, title: 'Organic'),
                LegendEntry(color: Colors.pink, title: 'Plastic'),
                LegendEntry(color: Colors.cyan, title: 'Recyclable'),
                LegendEntry(color: Colors.yellow, title: 'Other'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> get lineBarsData => [
        LineChartBarData(
          isCurved: true,
          color: Colors.green,
          barWidth: 8,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: wasteDataList
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.organic.toDouble()))
              .toList(),
        ),
        LineChartBarData(
          isCurved: true,
          color: Colors.pink,
          barWidth: 8,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: wasteDataList
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.plastic.toDouble()))
              .toList(),
        ),
        LineChartBarData(
          isCurved: true,
          color: Colors.cyan,
          barWidth: 8,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: wasteDataList
              .asMap()
              .entries
              .map((entry) => FlSpot(
                  entry.key.toDouble(), entry.value.recyclable.toDouble()))
              .toList(),
        ),
        LineChartBarData(
          isCurved: true,
          color: Colors.yellow,
          barWidth: 8,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: wasteDataList
              .asMap()
              .entries
              .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.other.toDouble()))
              .toList(),
        ),
      ];

  double getMaxY() {
    int maxY = 0;
    for (var wasteData in wasteDataList) {
      maxY = [
        wasteData.organic,
        wasteData.plastic,
        wasteData.recyclable,
        wasteData.other
      ].reduce((a, b) => a > b ? a : b);
    }
    return maxY.toDouble() + 5;
  }

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              return Text('${value.toInt() + 1}', style: style);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              return Text(value.toInt().toString(), style: style);
            },
            interval: 1,
            reservedSize: 40,
          ),
        ),
      );
}

class LegendEntry extends StatelessWidget {
  final Color color;
  final String title;

  LegendEntry({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.0),
        Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
