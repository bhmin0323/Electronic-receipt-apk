import 'dart:developer';

import 'package:e_receipt/Data_save.dart';
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
    _loadSavedData();
  }

  void _loadSavedData() async {
    final dataManager = DataManage();
    List<ReceiptDataModel> loadedReceipts =
        await dataManager.loadReceiptDataList();
    List<ReceiptStringModel> loadedReceiptTexts =
        await dataManager.loadReceiptTextList();

    setState(() {
      receiptList = loadedReceipts;
      receiptStringList = loadedReceiptTexts;
    });
  }

  void deleteReceipt(int index) async {
    setState(() {
      receiptList.removeAt(index);
      receiptStringList.removeAt(index);
    });
    log('${receiptList}');

    final dataManager = DataManage();
    await dataManager.saveReceiptDataList(receiptList);
    await dataManager.saveReceiptTextList(receiptStringList);
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
          final reversedIndex = receiptList.length - 1 - index;
          final receipt = receiptList[reversedIndex];
          final receiptString = receiptStringList[reversedIndex].getter();
          log((receiptStringList[index].getter()));
          return ReceiptWidget(
            index: reversedIndex,
            receipt: receipt,
            onDeleted: () => deleteReceipt(reversedIndex),
            receiptString: receiptString,
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
                        _loadSavedData();
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(top: 40.0), // FAB 위치를 고정
          child: ClipOval(
            child: SizedBox(
              width: 85,
              height: 85,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScanPage(
                        onReceiptAdded: () {
                          _loadSavedData(); // QR 스캔 후 데이터 리로드
                        },
                      ),
                    ),
                  );
                },
                backgroundColor: const Color.fromRGBO(0, 132, 96, 1),
                child: const Icon(
                  Icons.center_focus_weak_sharp,
                  size: 65, // 아이콘 크기
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
