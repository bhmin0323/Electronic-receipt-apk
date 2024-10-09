import 'package:e_receipt/route_navigator.dart';
import 'package:flutter/material.dart';
import 'QRcamera.dart'; // QR 스캔 페이지 임포트
import 'QRInfo.dart'; // QR 정보 페이지 임포트

// Receipt 모델 정의
class Receipt {
  final String receiptNumber;
  final String date;
  final String storeName;
  final int amount;

  Receipt({
    required this.receiptNumber,
    required this.date,
    required this.storeName,
    required this.amount,
  });
}

// 영수증 데이터를 파싱하는 함수
List<Receipt> parseReceiptData(String rawData) {
  List<Receipt> receipts = [];
  List<String> receiptStrings = rawData.split("\n\n"); // 두 줄바꿈으로 영수증 구분

  for (String receiptString in receiptStrings) {
    List<String> fields = receiptString.split('\n');
    if (fields.length == 4) {
      receipts.add(
        Receipt(
          receiptNumber: fields[0],
          date: fields[1],
          storeName: fields[2],
          amount: int.parse(fields[3]),
        ),
      );
    }
  }

  return receipts;
}

// 영수증 목록 페이지
class ReceiptListPage extends StatelessWidget {
  // 예시: 서버에서 받아온 영수증 문자열 데이터
  final String rawReceiptData = '''
영수증4\n24-09-15\n서브웨이\n10400\n\n
영수증3\n24-09-10\n롯데마트\n63400\n\n
영수증2\n24-09-05\n추억사진관\n14000\n\n
영수증1\n24-08-26\n빽다방\n7800
  ''';
  //   final String rawData;

  // ReceiptListPage({required this.rawData});

  @override
  Widget build(BuildContext context) {
    List<Receipt> receipts = parseReceiptData(rawReceiptData);

    return Scaffold(
      appBar: AppBar(
        title: Text("영수증 목록"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.receipt, color: Colors.grey),
                    title: Text(receipt.storeName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(receipt.date),
                        Text('금액: ${receipt.amount}원'),
                      ],
                    ),
                    trailing: Text(receipt.receiptNumber),
                  ),
                );
              },
            ),
          ),
          // QR 스캔 페이지로 이동하는 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QRpage()), // QR 스캔 페이지로 이동
                );
              },
              icon: Icon(Icons.qr_code_scanner),
              label: Text('QR 스캔'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // 버튼 색상
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: ReceiptListPage(),
      routes: Routes.routes,
    ));
