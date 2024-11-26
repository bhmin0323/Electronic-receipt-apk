import 'dart:developer';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:e_receipt/model/Receipt_model.dart';

class ReceiptWidget extends StatelessWidget {
  final int index;
  final ReceiptDataModel receipt;
  final VoidCallback onDeleted;
  final String receiptString;

  const ReceiptWidget({
    Key? key,
    required this.index,
    required this.receipt,
    required this.onDeleted,
    required this.receiptString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 영수증 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptDetailPage(
              index: index,
              onDeleted: () {
                Navigator.of(context).pop(context);
                onDeleted();
                // Navigator.pop(context);
              },
              receiptString: receiptString,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '영수증 ${index + 1}',
                  // style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${receipt.date}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${receipt.storeName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${receipt.totalPrice}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 20,
                  ),
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
                                onDeleted();
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
          ],
        ),
      ),
    );
  }
}
