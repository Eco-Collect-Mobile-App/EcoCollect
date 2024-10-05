import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import the qr_flutter package
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'dart:io'; // Import dart:io for file handling
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

class QRCodeGenerator extends StatelessWidget {
  final String requestId;

  // Constructor to receive the requestId
  QRCodeGenerator({required this.requestId});

  // Method to save QR code image to device
  Future<void> _saveQRCode() async {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      try {
        // Get the directory to save the file
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$requestId.png';

        // Create a QrPainter to render the QR code
        final qrPainter = QrPainter(
          data: requestId,
          version: QrVersions.auto,
          gapless: false,
          color: const Color(0xFF000000),
          embeddedImage: null,
          embeddedImageStyle: null,
        );

        // Save the QR code as an image file
        final byteData = await qrPainter.toImageData(300);
        final buffer = byteData!.buffer.asUint8List();
        final file = File(path);
        await file.writeAsBytes(buffer);

        // Show a success message
        print('QR Code saved to $path');
        // You can also show a Snackbar or a dialog to indicate success
      } catch (e) {
        print('Error saving QR Code: $e');
      }
    } else {
      print('Storage permission denied');
    }
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
        title: const Text("QR Code",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFFE7EBE8), // Set background color for the page
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Request ID: $requestId",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 72, 72, 72)),
              ),
              SizedBox(height: 10),
              Text(
                "Please present this QR code to the garbage collector upon their arrival for waste pickup.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 120, 120,
                      120), // Slightly lighter grey for the paragraph
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: 80),
              // Container to hold the QR code
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF), // Background color for QR code box
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 134, 246, 180),
                      blurRadius: 100,
                      offset: Offset(2, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(18), // Padding around the QR code
                child: QrImageView(
                  data: requestId, // Use requestId as the data for the QR code
                  version: QrVersions.auto,
                  size: 250.0, // Adjust the size of the QR code
                  gapless: false, // Set to true for no gaps
                ),
              ),
              SizedBox(height: 150),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18), // Button border radius
                  ),
                  textStyle: TextStyle(
                    fontSize: 18, // Button text size
                    fontWeight: FontWeight.w600, // Button text weight
                  ),
                ),
                onPressed: _saveQRCode,
                child: Text("Download QR Code"), // Button to download QR code
              ),
            ],
          ),
        ),
      ),
    );
  }
}
