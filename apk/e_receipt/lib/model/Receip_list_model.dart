import 'dart:developer';

import 'package:e_receipt/model/Receipt_model.dart';

class ReceiptListModel {
  final int rid;
  final ReceiptDataModel receiptData;
  final ReceiptStringModel receiptString;

  ReceiptListModel({
    required this.rid,
    required this.receiptData,
    required this.receiptString,
  });

  factory ReceiptListModel.fromJson(Map<String, dynamic> json) {
    return ReceiptListModel(
      rid: json['rid'],
      receiptData: ReceiptDataModel.fromJson(json['receiptData']),
      receiptString: ReceiptStringModel.fromtext(json['receiptString']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rid': rid,
      'receiptData': receiptData,
      'receiptString': receiptString.text,
    };
  }
}
