import 'dart:convert';

import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR 스캔')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) async {
            String? qrCode = scanData.code;
            final receiptData = await fetchReceiptData(qrCode!);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReceiptDetailPage(receiptData)),
            );
          });
        },
      ),
    );
  }

  Future<ReceiptData> fetchReceiptData(String qrCode) async {
    final response = await http
        .get(Uri.parse('https://your-server-url.com/receipt/$qrCode'));

    if (response.statusCode == 200) {
      return ReceiptData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load receipt data');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
