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
              onDeleted: () => onDeleted,
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
                  '영수증 ${index}',
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
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${receipt.totalPrice}원',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
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
