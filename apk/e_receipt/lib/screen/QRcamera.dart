import 'package:e_receipt/api/api.dart';
import 'package:e_receipt/route_navigator.dart';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRpage extends StatefulWidget {
  @override
  _QRpageState createState() => _QRpageState();
}

class _QRpageState extends State<QRpage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission(); // 카메라 권한 요청
  }

  void _requestCameraPermission() async {
    await Permission.camera.request(); // 카메라 권한 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR 스캔'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('QR 코드를 스캔하세요'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // 스캔된 QR 코드 데이터 처리
      final String qrText = scanData.code!;
      // 스캔 후 QRViewController를 일시 중지
      await controller.pauseCamera();
      //서버에 QR plain text 요청

      // QR 스캔 후 qrInfo 페이지로 이동
      Navigator.of(context, rootNavigator: true)
          .push(
        MaterialPageRoute(
          builder: (context) => qrInfo_Page(qrData: qrText),
        ),
      )
          .then((value) async {
        // QRInfo 페이지에서 돌아왔을 때 QRViewController 재개
        await controller.resumeCamera();
      });
    });
  }
}
