import 'package:e_receipt/model/Receipt_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataManage {
// ReceiptDataModel 리스트 저장
  Future<void> saveReceiptDataList(
      List<ReceiptDataModel> receiptDataList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonDataList = receiptDataList.map((receiptData) {
      return jsonEncode(receiptData.tojson());
    }).toList();
    await prefs.setStringList('receipt_data_list', jsonDataList);
  }

// ReceiptDataModel 리스트 불러오기
  Future<List<ReceiptDataModel>> loadReceiptDataList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonDataList = prefs.getStringList('receipt_data_list');
    if (jsonDataList != null) {
      return jsonDataList.map((jsonData) {
        Map<String, dynamic> jsonMap = jsonDecode(jsonData);
        return ReceiptDataModel.fromJson(jsonMap);
      }).toList();
    }
    return [];
  }

// ReceiptStringModel 리스트 저장
  Future<void> saveReceiptTextList(
      List<ReceiptStringModel> receiptTextList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> textList = receiptTextList.map((receiptText) {
      return receiptText.getter();
    }).toList();
    await prefs.setStringList('receipt_text_list', textList);
  }

// ReceiptStringModel 리스트 불러오기
  Future<List<ReceiptStringModel>> loadReceiptTextList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? textList = prefs.getStringList('receipt_text_list');
    if (textList != null) {
      return textList.map((text) {
        return ReceiptStringModel.fromtext(text);
      }).toList();
    }
    return [];
  }
}
