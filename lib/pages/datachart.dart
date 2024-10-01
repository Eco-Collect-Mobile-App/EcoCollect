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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final String? uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF27AE60), // Green color for the background
        title: const Text(
          'Dashboard', // Title of the header
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification,
                color: Colors.white), // Notification icon
            onPressed: () {
              // Add your notification button action here
            },
          ),
          const SizedBox(
              width:
                  20), // Add spacing between the notification icon and the edge
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('7D', 'Last 7 Days'),
                _buildFilterButton('30D', 'Last 30 Days'),
                _buildFilterButton('3M', 'Last 3 Months'),
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

                  // Parse and filter the waste data based on the selected period
                  List<FlSpot> plasticSpots = [];
                  List<FlSpot> organicSpots = [];
                  List<FlSpot> recyclableSpots = [];

                  // Get the current date and calculate the cutoff date based on the selected period
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

                  // Collect and sort the documents by 'pickupDate'
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

                  // Only include every second day in the sortedDocs
                  sortedDocs = sortedDocs
                      .asMap()
                      .entries
                      .where((entry) => entry.key % 2 == 0)
                      .map((entry) => entry.value)
                      .toList();

                  sortedDocs.asMap().forEach((index, doc) {
                    String pickupDate = doc['pickupDate'];
                    DateTime parsedDate = DateTime.parse(pickupDate);
                    double xValue =
                        index.toDouble(); // Use sorted index for X-axis

                    List wasteEntries = doc['wasteEntries'];
                    wasteEntries.forEach((entry) {
                      double weight = entry['weight']?.toDouble() ?? 0;

                      switch (entry['wasteType']) {
                        case 'Plastic':
                          plasticSpots.add(FlSpot(xValue, weight));
                          break;
                        case 'Organic':
                          organicSpots.add(FlSpot(xValue, weight));
                          break;
                        case 'Recyclable':
                          recyclableSpots.add(FlSpot(xValue, weight));
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
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        height: 350,
                        width: 350,
                        padding: const EdgeInsets.all(
                            16), // Padding between box and chart
                        child: LineChart(
                          LineChartData(
                            gridData: gridData,
                            titlesData: titlesData(sortedDocs),
                            borderData: borderData,
                            lineBarsData: [
                              lineChartBarData(
                                  plasticSpots, Colors.red), // Plastic (Red)
                              lineChartBarData(organicSpots,
                                  Colors.purple), // Organic (Purple)
                              lineChartBarData(recyclableSpots,
                                  Colors.green), // Recyclable (Green)
                            ],
                            minX: 0,
                            maxX: (sortedDocs.length - 1).toDouble(),
                            minY: 0,
                            maxY:
                                10, // Adjust the maxY based on the weight data
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF27AE60), // Green background
                        ),
                        onPressed: () async {
                          // Navigate to the UserGoals page and wait for the result (selected goals)
                          final selectedGoals = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserGoals(),
                            ),
                          );

                          if (selectedGoals != null &&
                              selectedGoals is List<String>) {
                            // Do something with the selected goals, e.g., save them to Firestore or update UI
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
              ? const Color(0xFF27AE60) // Active period button color
              : Colors.grey[300], // Inactive button color
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
}

// Function to create LineChartBarData for each waste type
LineChartBarData lineChartBarData(List<FlSpot> spots, Color color) {
  return LineChartBarData(
    isCurved: true,
    color: color,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: spots,
  );
}

// Customize the titles (bottom and left only)
FlTitlesData titlesData(List<QueryDocumentSnapshot> sortedDocs) => FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value.toInt() < sortedDocs.length) {
              var date =
                  DateTime.parse(sortedDocs[value.toInt()]['pickupDate']);
              return Text(DateFormat('MM/dd').format(date),
                  style: const TextStyle(fontSize: 12));
            }
            return const Text('');
          },
          interval: 1,
          reservedSize: 30,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            return Text(value.toString(), style: const TextStyle(fontSize: 12));
          },
          reservedSize: 40,
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

// Grid lines (optional)
FlGridData get gridData => FlGridData(show: true);

// Borders around the chart
FlBorderData get borderData => FlBorderData(
      show: true,
      border: const Border(
        bottom: BorderSide(color: Colors.black),
        left: BorderSide(color: Colors.black),
        right: BorderSide(color: Colors.transparent),
        top: BorderSide(color: Colors.transparent),
      ),
    );

// Example of AnotherPage for navigation

