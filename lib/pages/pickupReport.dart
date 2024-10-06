import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'dart:io';

class PickupReqReport extends StatefulWidget {
  @override
  _PickupReqReportState createState() => _PickupReqReportState();
}

class _PickupReqReportState extends State<PickupReqReport> {
  final FirebaseService _firebaseService = FirebaseService();
  String? selectedMonth;
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<DocumentSnapshot> filteredDocs = [];

  Future<void> _filterByMonth(String month) async {
    final monthIndex = months.indexOf(month) + 1;

    try {
      final snapshot = await _firebaseService.getWasteRequestsForUser().first;

      setState(() {
        filteredDocs = snapshot.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime pickupDate =
              DateFormat('yyyy-MM-dd').parse(data['pickupDate']);
          return pickupDate.month == monthIndex;
        }).toList();
      });
    } catch (e) {
      print('Error filtering by month: $e');
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Pickup Report for $selectedMonth",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              for (var doc in filteredDocs) _buildReportContent(doc),
            ],
          );
        },
      ),
    );

//download the report to the donloads folder
    final output = Directory('/storage/emulated/0/Download');
    final file = File("${output.path}/pickup_report_$selectedMonth.pdf");

    if (!(await output.exists())) {
      await output.create(recursive: true);
    }

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("PDF downloaded: ${file.path}"),
    ));
  }

  pw.Widget _buildReportContent(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List wasteEntries = data['wasteEntries'] ?? [];

    Map<String, double> wasteTotals = {};
    for (var entry in wasteEntries) {
      String wasteType = entry['wasteType'];
      double weight = entry['weight']?.toDouble() ?? 0;
      if (weight > 0) {
        wasteTotals[wasteType] = (wasteTotals[wasteType] ?? 0) + weight;
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Pickup Date: ${data['pickupDate']}"),
        pw.Text("Address: ${data['address']}"),
        pw.Text("Pickup Time: ${data['pickupTime']}"),
        pw.SizedBox(height: 10),
        pw.Text("Waste Details:"),
        pw.Table.fromTextArray(
          headers: ['Waste Type', 'Bags', 'Weight (kg)'],
          data: wasteEntries.map((entry) {
            return [
              entry['wasteType'],
              entry['bagCount']?.toString() ?? '0',
              entry['weight']?.toString() ?? '0.0'
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF27AE60),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text("Garbage Pick-ups Report",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFE7EBE8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedMonth,
              hint: Text("Select Month"),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
                _filterByMonth(value!);
              },
              items: months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(
                    month,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              style: const TextStyle(
                color: Colors.black,
              ),
              dropdownColor: Color.fromARGB(255, 208, 208, 208),
              iconEnabledColor: Colors.black,
              iconDisabledColor: Colors.grey,
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredDocs.isEmpty
                  ? Center(
                      child: Text("No records for $selectedMonth.",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)))
                  : ListView(
                      children: filteredDocs.map((DocumentSnapshot doc) {
                        Map<String, dynamic> data =
                            doc.data()! as Map<String, dynamic>;

                        List wasteEntries = data['wasteEntries'] ?? [];
                        List validWasteEntries = wasteEntries.where((entry) {
                          return entry['weight'] != null && entry['weight'] > 0;
                        }).toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          color: const Color(0xFFFFFEF8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Pickup Date: ${data['pickupDate']}"),
                                Text("Pickup Time: ${data['pickupTime']}"),
                                Text(
                                  "Total Bags: ${validWasteEntries.fold(0, (sum, e) => sum + (e['bagCount'] != null ? int.parse(e['bagCount']) : 0))}",
                                ),
                                Text(
                                    "Total Weight: ${data['wasteEntries']?.where((e) => e['weight'] != null).fold(0, (sum, e) => sum + (e['weight']?.toDouble() ?? 0))} kg"),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 20),
            Center(
                child: ElevatedButton(
                    onPressed: selectedMonth != null ? _generatePDF : null,
                    child: Text("Download Report for $selectedMonth"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5FAD46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor: Colors.white,
                    )))
          ],
        ),
      ),
    );
  }
}
