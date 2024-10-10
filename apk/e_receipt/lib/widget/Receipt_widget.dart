import 'dart:developer';
import 'package:e_receipt/screen/QRInfo.dart';
import 'package:flutter/material.dart';
import 'package:e_receipt/model/Receipt_model.dart';

class ReceiptWidget extends StatelessWidget {
  final int index;
  final ReceiptData receipt;
  final VoidCallback onDeleted;

  const ReceiptWidget({
    Key? key,
    required this.index,
    required this.receipt,
    required this.onDeleted,
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
              receipt,
              onDeleted: () => onDeleted,
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
                  '상호명: ${receipt.storeName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${receipt.totalPrice}원',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text('날짜: ${receipt.date}'),
            const Divider(),
            // 추가적인 영수증 항목을 원한다면 여기서 표시 가능
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // 삭제 로직
                    onDeleted();
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
