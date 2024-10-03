import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:iconsax/iconsax.dart';
import 'package:eco_collect/pages/preferences.dart';

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
                  switch (_selectedPeriod) {
                    case '30D':
                      cutoffDate = now.subtract(const Duration(days: 30));
                      break;
                    case '3M':
                      cutoffDate = now.subtract(const Duration(days: 90));
                      break;
                    case '7D':
                    default:
                      cutoffDate = now.subtract(const Duration(days: 7));
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
                      double weight = entry['weight']?.toDouble() ?? 0;

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
                            titlesData: titlesData(sortedDocs),
                            borderData: borderData,
                            lineBarsData: [
                              lineChartBarData(plasticSpots, Colors.red),
                              lineChartBarData(organicSpots, Colors.purple),
                              lineChartBarData(recyclableSpots, Colors.green),
                            ],
                            minX: 0,
                            maxX: (sortedDocs.length - 1).toDouble(),
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
                                _buildTotalBox('Plastic', totalPlastic),
                                _buildTotalBox('Organic', totalOrganic),
                              ],
                            ),
                            const SizedBox(
                                height:
                                    16), // Add some spacing between the two rows
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTotalBox('Recyclable', totalRecyclable),
                                _buildTotalBox('Other', totalOther),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedPeriod == period
              ? const Color(0xFF27AE60)
              : Colors.grey[300],
        ),
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: _selectedPeriod == period ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // Function to create total sum box
  Widget _buildTotalBox(String title, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${total.toStringAsFixed(2)} Kg', // Display total with 2 decimal places
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Function to create LineChartBarData for each waste type
LineChartBarData lineChartBarData(List<FlSpot> spots, Color color) {
  return LineChartBarData(
    spots: spots,
    isCurved: true,
    color: color,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    barWidth: 6,
  );
}

// Updated grid data to only show horizontal grid lines
FlGridData get gridData => FlGridData(
      show: true, // Enable grid data
      drawHorizontalLine: true, // Show horizontal grid lines
      horizontalInterval: 2, // Optional: Set interval for horizontal lines
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey
              .withOpacity(0.3), // Customize the color of horizontal lines
          strokeWidth: 1, // Set the width of the horizontal lines
        );
      },
      drawVerticalLine: false, // Disable vertical grid lines
    );

// Example titles data for the chart
FlTitlesData titlesData(List<QueryDocumentSnapshot> sortedDocs) {
  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: true),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        getTitlesWidget: (value, meta) {
          return Text(
            DateFormat('MM/dd')
                .format(DateTime.now().subtract(Duration(days: value.toInt()))),
            style: const TextStyle(fontSize: 10),
          );
        },
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

// Example border data for the chart
FlBorderData get borderData => FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(color: const Color(0xFF27AE60)),
        bottom: BorderSide(color: const Color(0xFF27AE60)),
      ),
    );
