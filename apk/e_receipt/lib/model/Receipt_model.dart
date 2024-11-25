import 'dart:convert';

class ReceiptDataModel {
  final String storeName;
  final String date;
  final String totalPrice;

  ReceiptDataModel({
    required this.storeName,
    required this.date,
    required this.totalPrice,
  });

  factory ReceiptDataModel.fromJson(Map<String, dynamic> json) {
    return ReceiptDataModel(
      storeName: json['storeName'],
      date: json['date'],
      totalPrice: json['totalPrice'],
    );
  }
  Map<String, dynamic> tojson() {
    return {
      'storeName': storeName,
      'date': date,
      'totalPrice': totalPrice,
    };
  }
}

class ReceiptStringModel {
  final String text;

  ReceiptStringModel({
    required this.text,
  });

  factory ReceiptStringModel.fromtext(String text) {
    return ReceiptStringModel(text: text);
  }
  String getter() {
    return text;
  }
}
