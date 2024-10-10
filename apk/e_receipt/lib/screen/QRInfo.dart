import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';

class ReceiptDetailPage extends StatefulWidget {
  final ReceiptData receipt;
  final VoidCallback onDeleted; // 삭제 콜백 추가

  ReceiptDetailPage(this.receipt, {required this.onDeleted}); // 수정된 부분

  @override
  _ReceiptDetailPageState createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  GlobalKey _globalKey = GlobalKey(); // 캡처할 위젯의 키

  Future<void> _captureAndSavePng() async {
    try {
      // RepaintBoundary로부터 이미지 생성
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 갤러리에 이미지 저장
      final result = await ImageGallerySaver.saveImage(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['isSuccess'] ? '이미지가 갤러리에 저장되었습니다.' : '저장 실패')));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('오류가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영수증 상세 페이지'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // 삭제 버튼 클릭 시
              widget.onDeleted(); // 삭제 콜백 호출
              Navigator.pop(context); // 상세 페이지 닫기
            },
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _globalKey, // RepaintBoundary로 위젯을 감싸고 GlobalKey 설정
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 여백 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('상호명: ${widget.receipt.storeName}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('날짜: ${widget.receipt.date}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('총 금액: ${widget.receipt.totalPrice}원',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text('항목 목록:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.receipt.items.length,
                itemBuilder: (context, index) {
                  final item = widget.receipt.items[index];
                  return Text('${item.name}: ${item.price}원',
                      style: TextStyle(fontSize: 16));
                },
              ),
              Spacer(), // 공간을 확보하여 버튼을 아래로 위치
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0), // 하단 여백 추가
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _captureAndSavePng,
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(0, 132, 96, 1),
                          onPrimary: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: 15.0), // 수직 패딩 조정
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text(
                          '이미지 저장',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
