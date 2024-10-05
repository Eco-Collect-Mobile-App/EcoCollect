import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:iconsax/iconsax.dart';
import 'package:eco_collect/pages/preferences.dart';
import 'package:pie_chart/pie_chart.dart';

class DataChart extends StatefulWidget {
  const DataChart({Key? key}) : super(key: key);

  @override
  _DataChartState createState() => _DataChartState();
}

class _DataChartState extends State<DataChart> {
  String _selectedPeriod = '7D'; // Default selected period
  double totalPlastic = 0.0;
  double totalOrganic = 0.0;
  double totalRecyclable = 0.0;
  double totalOther = 0.0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final String? uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification, color: Colors.white),
            onPressed: () {
              // Add your notification button action here
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('7D', '7 Days'),
                _buildFilterButton('30D', '30 Days'),
                _buildFilterButton('3M', '3 Months'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('wasteData')
                    .where('userId', isEqualTo: uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  // Reset totals for each stream update
                  totalPlastic = 0.0;
                  totalOrganic = 0.0;
                  totalRecyclable = 0.0;
                  totalOther = 0.0;

                  // Parse and filter the waste data based on the selected period
                  List<FlSpot> plasticSpots = [];
                  List<FlSpot> organicSpots = [];
                  List<FlSpot> recyclableSpots = [];

                  DateTime now = DateTime.now();
                  DateTime cutoffDate;
                  List<String> dateLabels = [];
                  switch (_selectedPeriod) {
                    case '30D':
                      cutoffDate = now.subtract(const Duration(days: 30));
                      for (int i = 0; i < 4; i++) {
                        dateLabels.insert(
                          0,
                          DateFormat('MM/dd')
                              .format(now.subtract(Duration(days: i * 7))),
                        );
                      }
                      break;
                    case '3M':
                      cutoffDate = now.subtract(const Duration(days: 90));
                      for (int i = 0; i < 3; i++) {
                        dateLabels.insert(
                          0,
                          DateFormat('MMMM yyyy')
                              .format(now.subtract(Duration(days: 30 * i))),
                        );
                      }
                      break;
                    case '7D':
                    default:
                      cutoffDate = now.subtract(const Duration(days: 7));
                      for (int i = 0; i < 7; i++) {
                        dateLabels.insert(
                          0,
                          DateFormat('MM/dd')
                              .format(now.subtract(Duration(days: i))),
                        );
                      }
                  }

                  List<QueryDocumentSnapshot> sortedDocs =
                      List.from(snapshot.data!.docs);
                  sortedDocs = sortedDocs.where((doc) {
                    DateTime pickupDate = DateTime.parse(doc['pickupDate']);
                    return pickupDate.isAfter(cutoffDate);
                  }).toList();

                  sortedDocs.sort((a, b) {
                    DateTime dateA = DateTime.parse(a['pickupDate']);
                    DateTime dateB = DateTime.parse(b['pickupDate']);
                    return dateA.compareTo(dateB);
                  });

                  sortedDocs = sortedDocs
                      .asMap()
                      .entries
                      .where((entry) => entry.key % 2 == 0)
                      .map((entry) => entry.value)
                      .toList();

                  sortedDocs.asMap().forEach((index, doc) {
                    String pickupDate = doc['pickupDate'];
                    DateTime parsedDate = DateTime.parse(pickupDate);
                    double xValue = index.toDouble();

                    List wasteEntries = doc['wasteEntries'];
                    wasteEntries.forEach((entry) {
                      double weight = entry['weight'] is String
                          ? double.parse(entry['weight'])
                          : entry['weight']?.toDouble() ?? 0.0;

                      switch (entry['wasteType']) {
                        case 'Plastic':
                          plasticSpots.add(FlSpot(xValue, weight));
                          totalPlastic += weight; // Sum Plastic weight
                          break;
                        case 'Organic':
                          organicSpots.add(FlSpot(xValue, weight));
                          totalOrganic += weight; // Sum Organic weight
                          break;
                        case 'Recyclable':
                          recyclableSpots.add(FlSpot(xValue, weight));
                          totalRecyclable += weight; // Sum Recyclable weight
                          break;
                        case 'Other':
                          totalOther += weight; // Sum Other weight
                          break;
                        default:
                          break;
                      }
                    });
                  });

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        height: 350,
                        width: 350,
                        padding: const EdgeInsets.all(16),
                        child: LineChart(
                          LineChartData(
                            gridData: gridData,
                            titlesData: titlesData(dateLabels),
                            borderData: borderData,
                            lineBarsData: [
                              lineChartBarData(plasticSpots, Colors.red),
                              lineChartBarData(organicSpots, Colors.purple),
                              lineChartBarData(recyclableSpots, Colors.green),
                            ],
                            minX: 0,
                            maxX: (dateLabels.length - 1).toDouble(),
                            minY: 0,
                            maxY: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Total sum boxes
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: _buildTotalBox(
                                    'Plastic',
                                    totalPlastic,
                                    Colors.red,
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: _buildTotalBox(
                                      'Organic', totalOrganic, Colors.purple),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: _buildTotalBox('Recyclable',
                                      totalRecyclable, Colors.green),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: _buildTotalBox(
                                      'Other', totalOther, Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pie chart to show total sums of each waste type
                      /*PieChart(
                        dataMap: {
                          "Plastic": totalPlastic,
                          "Organic": totalOrganic,
                          "Recyclable": totalRecyclable,
                          "Other": totalOther,
                        },
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 3,
                        colorList: [
                          Colors.red, // Plastic
                          Colors.purple, // Organic
                          Colors.green, // Recyclable
                          Colors.grey, // Other
                        ],
                        initialAngleInDegree: 0,
                        chartType: ChartType.disc,
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.right,
                          showLegends: true,
                          legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValueBackground: false,
                          showChartValues: true,
                          chartValueStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ), */

                      const SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5FAD46),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                        ),
                        onPressed: () async {
                          final selectedGoals = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserGoals(),
                            ),
                          );

                          if (selectedGoals != null &&
                              selectedGoals is List<String>) {
                            print('Selected Goals: $selectedGoals');
                          }
                        },
                        child: const Text(
                          'Generate your waste management plan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the filter button widget
  Widget _buildFilterButton(String period, String label) {
    bool isSelected = _selectedPeriod == period;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF5FAD46)
              : Colors.white, // Background color
          padding: const EdgeInsets.symmetric(
              vertical: 12.0, horizontal: 28.0), // Optional padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black, // Text color
            fontWeight: FontWeight.bold, // Optional: bold text
          ),
        ),
      ),
    );
  }

  // Build total box widget
  Widget _buildTotalBox(String label, double total, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} Kg',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Line chart bar data
  LineChartBarData lineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color, // Change from colors: [color] to color: color
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      barWidth: 6,
    );
  }

  // Line chart grid data
  FlGridData get gridData => FlGridData(show: true);

  // Line chart border data
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 1),
          left: BorderSide(color: Colors.black, width: 1),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  // Titles data with formatted labels
  FlTitlesData titlesData(List<String> dateLabels) => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  index >= 0 && index < dateLabels.length
                      ? dateLabels[index]
                      : '',
                ),
              );
            },
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Disable top titles
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Disable right titles
          ),
        ),
      );
}
