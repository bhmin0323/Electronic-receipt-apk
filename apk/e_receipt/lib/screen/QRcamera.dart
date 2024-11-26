import 'dart:convert';
import 'dart:developer';
import 'package:e_receipt/api/api.dart';
import 'package:e_receipt/model/Receipt_model.dart';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_receipt/Data_save.dart';

class QRScanPage extends StatefulWidget {
  final Function onReceiptAdded;

  QRScanPage({required this.onReceiptAdded});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  void _requestCameraPermission() async {
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR 스캔'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          if (controller != null) {
            controller!.resumeCamera();
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: QRView(
                key: qrKey,
                onQRViewCreated: (QRViewController controller) {
                  this.controller = controller;
                  controller.scannedDataStream.listen(
                    (scanData) async {
                      final String qrCode = scanData.code!;
                      await controller.pauseCamera();

                      final receiptString = await parseUrl(qrCode);
                      log('receipstring: ${receiptString}');

                      if (receiptString == '-1') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('서버연결 오류${receiptString}'),
                              content:
                                  const Text("서버에 연결할 수 없습니다.\n다시 시도해주세요."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("확인"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          },
                        ).then((_) {
                          controller.resumeCamera();
                        });
                      } else if (receiptString == '404') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("QR 오류"),
                              content: const Text("만료된 QR코드입니다."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("확인"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          },
                        ).then((_) {
                          controller.resumeCamera();
                        });
                      } else {
                        final receiptData = parseReceiptData(receiptString);

                        final receiptModel =
                            ReceiptDataModel.fromJson(receiptData);
                        final receiptTextModel =
                            ReceiptStringModel.fromtext(receiptString);

                        await _saveReceiptData(receiptModel, receiptTextModel);
                        widget.onReceiptAdded();

                        if (mounted) {
                          // BuildContext가 여전히 유효한지 확인
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptDetailPage(
                                index: -1,
                                receiptString: receiptString,
                                onDeleted: () async {
                                  // 수정: 상세 페이지에서 삭제 시 저장소 업데이트
                                  final dataManager = DataManage();
                                  final currentDataList =
                                      await dataManager.loadReceiptDataList();
                                  final currentStringList =
                                      await dataManager.loadReceiptTextList();

                                  currentDataList.removeLast();
                                  currentStringList.removeLast();

                                  await dataManager
                                      .saveReceiptDataList(currentDataList);
                                  await dataManager
                                      .saveReceiptTextList(currentStringList);

                                  widget.onReceiptAdded(); // 메인 페이지 업데이트
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ).then((_) {
                            // ReceiptDetailPage에서 돌아왔을 때 카메라를 다시 시작하도록 설정
                            controller.resumeCamera();
                          });
                        }
                      }
                    },
                  );
                },
              ),
            ),
            const Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '확인할 영수증의 QR코드를 스캔하세요.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> parseUrl(String url) async {
    Uri uri = Uri.parse(url);
    try {
      // id와 hash 값 추출
      String? id = uri.queryParameters['id'];
      String? hash = uri.queryParameters['hash'];

      log("$id,$hash");

      final pltext = await ApiService().getInfo(id!, hash!);
      if (pltext == '-1') {
        return '-1';
      }

      return pltext;
    } catch (e) {
      return '-1';
    }
  }

  Future<void> _saveReceiptData(
      ReceiptDataModel receiptData, ReceiptStringModel receiptString) async {
    final dataManager = DataManage();
    final currentDataList = await dataManager.loadReceiptDataList();
    final currentStringList = await dataManager.loadReceiptTextList();

    currentDataList.add(receiptData);
    currentStringList.add(receiptString);

    await dataManager.saveReceiptDataList(currentDataList);
    await dataManager.saveReceiptTextList(currentStringList);
  }

  // 필요한 데이터 파싱
  Map<String, dynamic> parseReceiptData(String receiptString) {
    log('${receiptString}');
    // 상호
    RegExp merchantRegExp = RegExp(r'상호:\s*(.*)');
    String? storeName =
        merchantRegExp.firstMatch(receiptString)?.group(1)?.trim();
    log('${storeName}');
    // 거래일시
    RegExp dateRegExp = RegExp(r'거래일시:\s*(\d{4}-\d{2}-\d{2})');
    String? date = dateRegExp.firstMatch(receiptString)?.group(1);
    log('${date}');
    // 총 합계
    RegExp totalAmountRegExp = RegExp(r'총 합 계:\s*([\d,]+원)');
    String? totalPrice = totalAmountRegExp.firstMatch(receiptString)?.group(1);
    log('${totalPrice}');

    return {
      'storeName': storeName,
      'date': date,
      'totalPrice': totalPrice,
    };
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
