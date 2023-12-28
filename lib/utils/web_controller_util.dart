import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebControllerUtil {
  static void backPage(WebViewController webViewController) async {
    DateTime? currentBackPressTime;
    DateTime now = DateTime.now();
    String morePressButton = "뒤로가기 버튼을 한번 더 누르면 종료됩니다";

    if (await webViewController.canGoBack()) {
      webViewController.goBack();
    } else {
      if (currentBackPressTime != null) {
        if (now.difference(currentBackPressTime!) < Duration(seconds: 3)) {
          exit(0);
        } else {
          Fluttertoast.showToast(msg: morePressButton);
          currentBackPressTime = now;
        }
      } else {
        Fluttertoast.showToast(msg: morePressButton);
        currentBackPressTime = now;
      }
    }
  }
}