import 'dart:convert';
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
  void initState() {
    super.initState();
    _requestCameraPermission(); // 카메라 권한 요청 함수 호출
  }

  void _requestCameraPermission() async {
    await Permission.camera.request(); // 카메라 권한 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR 스캔'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) async {
                  String? qrCode = scanData.code;
                  final receiptData = await fetchReceiptData(qrCode!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptDetailPage(
                        receiptData,
                        onDeleted: () {},
                      ),
                    ),
                  ).then((_) {
                    Navigator.pop(context, receiptData);
                  });
                });
              },
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '확인할 영수증의 QR코드를 스캔하세요.',
                style: TextStyle(
                    fontSize: 18,
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
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
