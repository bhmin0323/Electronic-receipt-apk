import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';

class ReceiptDetailPage extends StatefulWidget {
  final String receiptString;
  // final Future<ReceiptDataModel> receiptData;
  final VoidCallback onDeleted; // 삭제 콜백 추가

  ReceiptDetailPage({
    required this.onDeleted,
    required this.receiptString,
    // required this.receiptData,
  }); // 수정된 부분

  @override
  _ReceiptDetailPageState createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  GlobalKey _captureKey = GlobalKey(); // 캡처할 위젯의 키

  @override
  void initState() {
    super.initState();
    // State에서 직접 receiptString을 초기화
    receiptString = widget.receiptString;
  }

  late final String receiptString;
  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // 캡처 이미지 생성
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 배경색 적용
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      Paint paint = Paint()..color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          paint);

      canvas.drawImage(image, Offset.zero, Paint());
      ui.Image finalImage =
          await recorder.endRecording().toImage(image.width, image.height);

      ByteData? finalByteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List finalPngBytes = finalByteData!.buffer.asUint8List();

      // 갤러리에 이미지 저장
      final result = await ImageGallerySaver.saveImage(finalPngBytes);

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
        title: Text('영수증'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDeleted(); // 삭제 콜백 호출
              Navigator.pop(context); // 상세 페이지 닫기
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RepaintBoundary(
            key: _captureKey, // 캡처할 텍스트만 감싸기
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35.0, 35.0, 35.0, 1.0),
              // 왼쪽: 24, 위: 32, 오른쪽: 24, 아래: 8
              child: Text(
                receiptString,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansKR',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // 하단 여백
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _captureAndSavePng,
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(0, 132, 96, 1),
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
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
    );
  }
}
