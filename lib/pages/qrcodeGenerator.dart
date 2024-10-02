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
        title: Text("QR Code Generator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "This is the QR Code for request ID: $requestId",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // Generate the QR code
            QrImageView(
              data: requestId, // Use requestId as the data for the QR code
              version: QrVersions.auto,
              size: 200.0, // Adjust the size of the QR code
              gapless: false, // Set to true for no gaps
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQRCode,
              child: Text("Download QR Code"), // Button to download QR code
            ),
          ],
        ),
      ),
    );
  }
}
