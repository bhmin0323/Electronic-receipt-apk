import 'dart:developer';

import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/widget/Receipt_widget.dart';
import 'package:flutter/material.dart';
import 'QRcamera.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ReceiptDataModel> receiptList = [];
  List<ReceiptStringModel> receiptStringList = [];

  @override
  void initState() {
    super.initState();
    // 샘플 영수증 데이터 추가
    _loadSampleData();
  }

  void _loadSampleData() {
    setState(() {
      receiptList = [
        ReceiptDataModel(
          storeName: '롯데마트',
          date: '2024-10-10',
          totalPrice: 3500,
        ),
        ReceiptDataModel(
          storeName: '이마트',
          date: '2024-10-09',
          totalPrice: 4300,
        ),
      ];
      receiptStringList = [
        ReceiptStringModel(text: '''상호: 상도동주민들
사업자번호: 123-45-67890 
TEL: 02-820-0114
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
'''),
        ReceiptStringModel(text: '''상호: 상도동주민들
사업자번호: 123-45-67890 
TEL: 02-820-0114
대표자: 이지민
주소: 서울특별시 동작구 상도로 369
------------------------------------------
상품명           단가      수량      금액 
------------------------------------------
과세물품:                        50,000원
부 가 세:                        15,000원
총 합 계:                        65,000원
------------------------------------------
거래일시: 24/10/07 13:53:05
------------------------------------------
                              전자서명전표

찾아주셔서 감사합니다. (고객용)
\n\n\n\n\n\n
'''),
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
          log((receiptStringList.last.getter()));
          return ReceiptWidget(
            index: index,
            receipt: receipt,
            onDeleted: () => deleteReceipt(index),
            receiptString: receiptStringList[index].getter(),
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
