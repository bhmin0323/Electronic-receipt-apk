import 'package:flutter/material.dart';
import 'package:e_receipt/screen/QRInfo.dart';

class Routes {
  Routes._();

  // static const String certifypage = '/';
  static const String listpage = '/list';

  static final routes = <String, WidgetBuilder>{
    // certifypage: (BuildContext context) => Certify_Page(),
    listpage: (BuildContext context) => qrInfo_Page(
          qrData: '',
        ),
  };
}
