import 'package:flutter/material.dart';

class qrInfo_Page extends StatelessWidget {
  final String qrData;

  qrInfo_Page({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR 정보'),
      ),
      body: Center(
        child: Text('스캔된 데이터: $qrData'),
      ),
    );
  }
}
