import 'dart:convert';
import 'dart:developer';
import 'package:e_receipt/api/api.dart';
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                controller.scannedDataStream.listen(
                  (scanData) async {
                    final String qrCode = scanData.code!;
                    await controller.pauseCamera();

                    final receiptString = (await parseUrl(qrCode))
                        .replaceAll(RegExp(r'\n{6}$'), '');
                    final receiptData = parseReceiptData(receiptString);

                    final receiptModel = ReceiptDataModel.fromJson(receiptData);
                    final receiptTextModel =
                        ReceiptStringModel.fromtext(receiptString);

                    await _saveReceiptData(receiptModel, receiptTextModel);

                    if (mounted) {
                      // BuildContext가 여전히 유효한지 확인
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
                  },
                );
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

  Future<String> parseUrl(String url) async {
    // URL을 Uri 객체로 변환
    Uri uri = Uri.parse(url);

    // id와 hash 값 추출
    String? id = uri.queryParameters['id'];
    String? hash = uri.queryParameters['hash'];

    log("$id,$hash");

    final pltext = await ApiService().getInfo(id!, hash!);

    return pltext;
  }

  Future<void> _saveReceiptData(
      ReceiptDataModel receiptData, ReceiptStringModel receiptString) async {
    final prefs = await SharedPreferences.getInstance();

    // 기존의 영수증 리스트 불러오기
    List<String>? receiptDataList = prefs.getStringList('receipt_data_list');
    List<String>? receiptStringList = prefs.getStringList('receipt_text_list');

    // 영수증 리스트가 없으면 새 리스트 생성
    receiptDataList = receiptDataList ?? [];
    receiptStringList = receiptStringList ?? [];

    // 새로운 영수증 데이터 추가
    receiptDataList.add(jsonEncode(receiptData));
    receiptStringList.add(receiptString.getter());

    // 업데이트된 리스트 저장
    await prefs.setStringList('receipt_data_list', receiptDataList);
    await prefs.setStringList('receipt_text_list', receiptStringList);
  }

//   Future<String> fetchReceiptData(String qrCode) async {
//     // 서버에서 QR 코드로 받은 영수증 string 데이터를 fetch합니다.
//     // 예시용으로 string 데이터를 바로 반환
//     return Future.value('''상호: 상도동주민들
// 사업자번호: 123-45-67890  TEL: 02-820-0114
// 대표자: 이지민
// 주소: 서울특별시 동작구 상도로 369
// ------------------------------------------
// 상품명           단가      수량      금액
// ------------------------------------------
// 과세물품:                       150,000원
// 부 가 세:                        15,000원
// 총 합 계:                       165,000원
// ------------------------------------------
// 거래일시: 2024-10-07 13:53:05
// ------------------------------------------
//                               전자서명전표

// 찾아주셔서 감사합니다. (고객용)
// \n\n\n\n\n\n
// ''');
//   }

  // 필요한 데이터만 파싱하여 json으로 저장
  Map<String, dynamic> parseReceiptData(String receiptString) {
    // 상호 추출
    RegExp merchantRegExp = RegExp(r'상호:\s*(.*)');
    String? storeName = merchantRegExp.firstMatch(receiptString)?.group(1);

    // 총 합계 추출
    RegExp totalAmountRegExp = RegExp(r'총 합 계:\s*([\d,]+원)');
    String? totalPrice = totalAmountRegExp.firstMatch(receiptString)?.group(1);

    // 거래일시 추출
    RegExp dateRegExp =
        RegExp(r'거래일시:\s*(\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2})');
    String? date = dateRegExp.firstMatch(receiptString)?.group(1);

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
