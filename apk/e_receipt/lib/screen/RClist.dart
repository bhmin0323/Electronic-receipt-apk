import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/widget/Receipt_widget.dart';
import 'package:flutter/material.dart';
import 'QRcamera.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ReceiptData> receiptList = [];

  @override
  void initState() {
    super.initState();
    // 샘플 영수증 데이터 추가
    _loadSampleData();
  }

  void _loadSampleData() {
    setState(() {
      receiptList = [
        ReceiptData(
          storeName: '롯데마트',
          date: '2024-10-10',
          items: [
            ReceiptItem(name: '사과', price: 2000),
            ReceiptItem(name: '바나나', price: 1500),
          ],
          totalPrice: 3500,
        ),
        ReceiptData(
          storeName: '이마트',
          date: '2024-10-09',
          items: [
            ReceiptItem(name: '우유', price: 2500),
            ReceiptItem(name: '빵', price: 1800),
          ],
          totalPrice: 4300,
        ),
      ];
    });
  }

  void deleteReceipt(int index) {
    setState(() {
      receiptList.removeAt(index);
    });
  }

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
              Image.asset(
                'assets/logos/ER_appbar_logo.png',
                width: 110,
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
          return ReceiptWidget(
            index: index,
            receipt: receipt,
            onDeleted: () => deleteReceipt(index),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 150.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.list_alt_rounded,
                      color: Color.fromRGBO(0, 132, 96, 1),
                      size: 35,
                    ),
                    onPressed: () {
                      if (receiptList.isNotEmpty) {
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 500),
                        );
                      }
                    },
                  ),
                  // const Text(
                  //   '목록',
                  //   style: TextStyle(color: Color.fromRGBO(0, 132, 96, 1)),
                  // ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 35,
                    ),
                    onPressed: () {
                      // 검색 기능 (날짜 및 상호명 검색)
                    },
                  ),
                  // const Text('검색', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment(0.0, 0.95), // FAB 위치
        child: ClipOval(
          // 원형 모양 유지
          child: SizedBox(
            width: 70, // 원하는 너비
            height: 70, // 원하는 높이
            child: FloatingActionButton(
              onPressed: () async {
                // QR 스캔 페이지로 이동하고 스캔 결과를 받아오기
                final receiptData = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanPage()),
                );

                // 결과가 null이 아닐 경우 receiptList에 추가
                if (receiptData != null) {
                  setState(() {
                    receiptList.add(receiptData);
                  });
                }
              },
              backgroundColor: const Color.fromRGBO(0, 132, 96, 1),
              child: const Icon(
                Icons.center_focus_weak_sharp,
                size: 48, // 아이콘 크기
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
