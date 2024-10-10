import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReceiptDetailPage extends StatefulWidget {
  ReceiptDetailPage(ReceiptData receipt);

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

      // 로컬 파일에 이미지 저장
      final directory = (await getApplicationDocumentsDirectory()).path;
      File imgFile = File('$directory/screenshot.png');
      await imgFile.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지가 저장되었습니다: $directory/screenshot.png')));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('영수증 상세 페이지')),
      body: RepaintBoundary(
        key: _globalKey, // RepaintBoundary로 위젯을 감싸고 GlobalKey 설정
        child: Column(
          children: [
            // 여기에 영수증 데이터를 표시하는 위젯들 추가
            Text('상호명: 롯데마트'),
            Text('금액: 63,800원'),
            // 기타 영수증 데이터들...
            ElevatedButton(
              onPressed: _captureAndSavePng, // 버튼을 누르면 화면 캡처
              child: Text('이미지 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
