import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_url/utils/app_util.dart';
import 'package:open_url/widget/commons/default_body.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {

  String phoneNum;
  String model;
  String uniqueNum;

  WebViewScreen(this.phoneNum, this.model, this.uniqueNum, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebViewBody(phoneNum, model, uniqueNum);
  }
}

class WebViewBody extends DefaultBody {
  String phoneNum;
  String model;
  String uniqueNum;
  String curerntUrl = "";
  DateTime? currentBackPressTime;
  String BASE_URL = "";
  WebViewController _controller = WebViewController();

  WebViewBody(this.phoneNum, this.model, this.uniqueNum, {Key? key}) : super(key: key);

  @override
  Future<void> onStart(Duration timeStamp) async {
    Uri uri = Uri.parse(BASE_URL);
    _controller..loadRequest(uri)..setJavaScriptMode(JavaScriptMode.unrestricted)..runJavaScript("document.getElementsByTagName('header')[0].style.display='none'");

    await launchUrl(uri);
  }

  @override
  Widget buildBody(BuildContext context) {
    BASE_URL = "http://mtecsoft.co.kr:5800/pms/mobile/HpCheck.do?hpAuthNum=$phoneNum&model=$model&uniqueNum=$uniqueNum";

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        _controller.currentUrl().then((value) => curerntUrl = value ?? "");
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return Future(() => false);
        } else {
          if(currentBackPressTime != null) {
            if(now.difference(currentBackPressTime!) < Duration(seconds: 3)){
              return Future(() => true);
            }
            else {
              Fluttertoast.showToast(msg: "뒤로가기 버튼을 한번 더 누르면 종료됩니다");
              currentBackPressTime = now;
              return Future(() => false);
            }
          } else {
            Fluttertoast.showToast(msg: "뒤로가기 버튼을 한번 더 누르면 종료됩니다");
            currentBackPressTime = now;
            return Future(() => false);
          }
        }
      },
      child: InAppWebView(),
    );
  }
}
