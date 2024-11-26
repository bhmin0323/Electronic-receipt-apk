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
  List<ReceiptDataModel> filteredList = [];
  final ScrollController _scrollController = ScrollController();
  bool isFiltering = false;
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
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
      filteredList = loadedReceipts; // 기본적으로 전체 리스트 표시
    });
  }

  void deleteReceipt(int index) async {
    setState(() {
      receiptList.removeAt(index);
      receiptStringList.removeAt(index);
      filteredList = receiptList;
    });

    final dataManager = DataManage();
    await dataManager.saveReceiptDataList(receiptList);
    await dataManager.saveReceiptTextList(receiptStringList);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } else {
      log("ScrollController가 연결되어 있지 않습니다.");
    }
  }

  void _searchReceipts(String query) {
    setState(() {
      if (query.isEmpty) {
        isFiltering = false;
        filteredList = receiptList;
      } else {
        isFiltering = true;
        filteredList = receiptList
            .where((receipt) =>
                receipt.storeName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        filteredList = receiptList.where((receipt) {
          DateTime receiptDate = DateTime.parse(receipt.date);

          DateTime startDateTime =
              DateTime(startDate!.year, startDate!.month, startDate!.day);
          DateTime endDateTime =
              DateTime(endDate!.year, endDate!.month, endDate!.day)
                  .add(Duration(days: 1));

          return receiptDate.isAtSameMomentAs(startDateTime) ||
              receiptDate.isAtSameMomentAs(endDateTime) ||
              (receiptDate.isAfter(startDateTime) &&
                  receiptDate.isBefore(endDateTime));
        }).toList();
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  Future<void> _openDateRangeDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('날짜 범위 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    '시작일',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          startDate == null
                              ? 'YYYY-MM-DD'
                              : '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color:
                                startDate == null ? Colors.grey : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    '종료일',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          endDate == null
                              ? 'YYYY-MM-DD'
                              : '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: endDate == null ? Colors.grey : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (startDate != null && endDate != null) {
                    _filterByDateRange();
                    Navigator.of(context).pop();
                  } else {
                    // Optional: Show a message if dates are not selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('시작일과 종료일을 모두 선택해주세요.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text(
                  '검색',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(left: 12, right: 0),
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
        backgroundColor: const Color.fromRGBO(0, 132, 96, 1),
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 화면 클릭 시 검색창 닫기
        },
        child: Column(
          children: [
            if (isSearchVisible)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 검색창
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "상호명을 입력하세요...",
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: _searchReceipts,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    // const SizedBox(height: 10), // 검색창과 아이콘 사이 간격
                    // 날짜 검색 아이콘
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        _openDateRangeDialog(context); // 날짜 범위 검색 창 열기
                      },
                    ),
                  ],
                ),
                //   ],
                // ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final reversedIndex = filteredList.length - 1 - index;
                  final receipt = filteredList[reversedIndex];
                  final receiptString =
                      receiptStringList[reversedIndex].getter();
                  return ReceiptWidget(
                    index: reversedIndex,
                    receipt: receipt,
                    onDeleted: () => deleteReceipt(reversedIndex),
                    receiptString: receiptString,
                  );
                },
              ),
            ),
          ],
        ),
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
                          _scrollToTop();
                          _loadSavedData();
                        }),
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
                        setState(() {
                          // search 아이콘 클릭 시 검색창 보이기/숨기기
                          isSearchVisible = !isSearchVisible;
                        });
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
          padding: const EdgeInsets.only(top: 40.0),
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
                        onReceiptAdded: _loadSavedData,
                      ),
                    ),
                  );
                },
                backgroundColor: const Color.fromRGBO(0, 132, 96, 1),
                child: const Icon(
                  Icons.center_focus_weak_sharp,
                  size: 62,
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
