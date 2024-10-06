import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class QRCodeGenerator extends StatelessWidget {
  final String requestId;

  QRCodeGenerator({required this.requestId});

  Future<void> _saveQRCode() async {
    if (await Permission.storage.request().isGranted) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$requestId.png';
        final qrPainter = QrPainter(
          data: requestId,
          version: QrVersions.auto,
          gapless: false,
          color: const Color(0xFF000000),
          embeddedImage: null,
          embeddedImageStyle: null,
        );
        final byteData = await qrPainter.toImageData(300);
        final buffer = byteData!.buffer.asUint8List();
        final file = File(path);
        await file.writeAsBytes(buffer);

        print('QR Code saved to $path');
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
        color: Color(0xFFE7EBE8),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Request ID: $requestId",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 72, 72, 72)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please present this QR code to the garbage collector upon their arrival for waste pickup.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 120, 120, 120),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 80),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 134, 246, 180),
                      blurRadius: 100,
                      offset: Offset(2, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(18),
                child: QrImageView(
                  data: requestId,
                  version: QrVersions.auto,
                  size: 250.0,
                  gapless: false,
                ),
              ),
              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
