import 'dart:convert';
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
    _requestCameraPermission();
  }

  void _requestCameraPermission() async {
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR 스캔'),
        centerTitle: true,
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
                  if (qrCode != null) {
                    final receiptString = (await fetchReceiptData(qrCode))
                        .replaceAll(RegExp(r'\n{6}$'), '');
                    final receiptData = parseReceiptData(receiptString);

                    ReceiptDataModel.fromJson(receiptData);
                    ReceiptStringModel.fromtext(receiptString);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptDetailPage(
                          receiptString: receiptString,
                          onDeleted: () {},
                        ),
                      ),
                    );
                  }
                });
              },
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '확인할 영수증의 QR코드를 스캔하세요.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> fetchReceiptData(String qrCode) async {
    // 서버에서 QR 코드로 받은 영수증 string 데이터를 fetch합니다.
    // 예시용으로 string 데이터를 바로 반환
    return Future.value('''상호: 상도동주민들
        사업자번호: 123-45-67890  TEL: 02-820-0114
대표자: 이지민
주소: 서울특별시 동작구 상도로 369
------------------------------------------
상품명           단가      수량      금액 
------------------------------------------
과세물품:                       150,000원
부 가 세:                        15,000원
총 합 계:                       165,000원
------------------------------------------
거래일시: 24/10/07 13:53:05
------------------------------------------
                              전자서명전표

찾아주셔서 감사합니다. (고객용)
\n\n\n\n\n\n
''');
  }

  // 필요한 데이터만 파싱하여 json으로 저장
  Map<String, dynamic> parseReceiptData(String receiptString) {
    final storeNameRegex = RegExp(r'상호: (.+)');
    final totalPriceRegex = RegExp(r'총 합 계: ([\d,]+)원');
    final dateRegex = RegExp(r'거래일시: (.+)');

    final storeName = storeNameRegex.firstMatch(receiptString)?.group(1) ?? '';
    final totalPrice =
        totalPriceRegex.firstMatch(receiptString)?.group(1) ?? '';
    final date = dateRegex.firstMatch(receiptString)?.group(1) ?? '';

    return {
      'storeName': storeName,
      'date': date,
      'totalPrice': totalPrice,
    };
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// class ReceiptDetailPage extends StatelessWidget {
//   final String receiptString; // 영수증 원본 string 데이터
//   final Map<String, dynamic> receiptData; // 파싱된 json 데이터

//   ReceiptDetailPage({
//     required this.receiptString,
//     required this.receiptData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('영수증 상세'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 영수증 원본 string 데이터 표시
//             Text('영수증 원본:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             Text(receiptString),
//             SizedBox(height: 20),
//             // 파싱된 json 데이터 표시
//             Text('상호명: ${receiptData['storeName']}'),
//             Text('총 합계: ${receiptData['totalPrice']}원'),
//             Text('거래일시: ${receiptData['date']}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
