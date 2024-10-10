import 'dart:convert';

class ReceiptData {
  final String storeName;
  final String date;
  final List<ReceiptItem> items;
  final int totalPrice;

  ReceiptData({
    required this.storeName,
    required this.date,
    required this.items,
    required this.totalPrice,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<ReceiptItem> itemList =
        itemsFromJson.map((i) => ReceiptItem.fromJson(i)).toList();

    return ReceiptData(
      storeName: json['storeName'],
      date: json['date'],
      items: itemList,
      totalPrice: json['totalPrice'],
    );
  }
}

class ReceiptItem {
  final String name;
  final int price;

  ReceiptItem({required this.name, required this.price});

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'],
      price: json['price'],
    );
  }
}
