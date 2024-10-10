import 'package:e_receipt/model/Receipt_model.dart';
import 'package:flutter/material.dart';
import 'QRInfo.dart';
import 'QRcamera.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ReceiptData> receiptList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Test",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(0, 132, 96, 1),
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: ListView.builder(
        itemCount: receiptList.length,
        itemBuilder: (context, index) {
          final receipt = receiptList[index];
          return ListTile(
            title: Text(receipt.storeName),
            subtitle: Text(receipt.date),
            trailing: Text('${receipt.totalPrice}원'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReceiptDetailPage(receipt)),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // 메인 페이지 최상단 이동
                if (receiptList.isNotEmpty) {
                  Scrollable.ensureVisible(
                    context,
                    duration: Duration(milliseconds: 500),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 검색 기능 (날짜 및 상호명 검색)
              },
            ),
          ],
        ),
      ),
    );
  }
}
