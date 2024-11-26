import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';

class ReceiptDetailPage extends StatefulWidget {
  final int index;
  final String receiptString;
  // final Future<ReceiptDataModel> receiptData;
  final VoidCallback onDeleted; // 삭제 콜백 추가

  ReceiptDetailPage({
    required this.index,
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

  String _receiptNum() {
    if (widget.index == -1) {
      return '영수증';
    } else {
      return '영수증 ${widget.index + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_receiptNum()}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("영수증 삭제"),
                    content: const Text("이 영수증을 삭제하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("취소"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onDeleted();
                          Navigator.of(context).pop(context);
                        },
                        child: const Text("삭제"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _captureKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35.0, 35.0, 35.0, 35.0),
            child: Text(
              widget.receiptString,
              style: TextStyle(
                fontSize: screenWidth * 0.0348,
                fontFamily: "consola",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        color: Colors.white, // 배경색 지정
        child: ElevatedButton(
          onPressed: _captureAndSavePng,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromRGBO(0, 132, 96, 1),
            textStyle: const TextStyle(fontSize: 18),
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: screenWidth * 0.1,
            ),
          ),
          child: Text(
            '이미지 저장',
            style: TextStyle(fontSize: screenWidth * 0.05),
          ),
        ),
      ),
    );
  }
}
