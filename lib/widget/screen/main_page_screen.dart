import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_url/bloc/device_info_bloc.dart';
import 'package:open_url/utils/app_util.dart';
import 'package:open_url/widget/commons/default_body.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainPageScreen extends StatelessWidget {
  const MainPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeviceBloc>(create: (context) => DeviceBloc()),
      ],
      child: _Body(),
    );
  }
}

class _Body extends DefaultBody {
  WebViewController _controller = WebViewController();

  _Body({Key? key}) : super(key: key);

  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.keyboard_backspace_rounded),
            onPressed: () {
              _moveToBackPage();
            }),
        body: Column(
          children: [
            Expanded(child: DeviceInfo(_controller)),
          ],
        ),
      ),
    );
  }

  DateTime? currentBackPressTime;

  void _moveToBackPage() async {
    DateTime now = DateTime.now();

    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      if (currentBackPressTime != null) {
        if (now.difference(currentBackPressTime!) < Duration(seconds: 3)) {
          exit(0);
        } else {
          Fluttertoast.showToast(msg: "뒤로가기 버튼을 한번 더 누르면 종료됩니다");
          currentBackPressTime = now;
        }
      } else {
        Fluttertoast.showToast(msg: "뒤로가기 버튼을 한번 더 누르면 종료됩니다");
        currentBackPressTime = now;
      }
    }
  }
}

class DeviceInfo extends DefaultBody {
  WebViewController _controller;
  late DeviceBloc deviceBloc;

  DeviceInfo(this._controller, {Key? key}) : super(key: key);

  @override
  void onStart(Duration timeStamp) {
    _getPhoneInfo();
  }

  void _getPhoneInfo() {
    deviceBloc = buildContext.read<DeviceBloc>();
    deviceBloc.getDeviceInfo();
  }

  Future<bool> _future(DateTime? currentBackPressTime) async {
    DateTime now = DateTime.now();

    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future(() => false);
    } else {
      if (currentBackPressTime != null) {
        if (now.difference(currentBackPressTime!) < Duration(seconds: 3)) {
          return Future(() => true);
        } else {
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
  }

  @override
  Widget buildBody(BuildContext context) {
    DateTime? currentBackPressTime;

    return WillPopScope(
      onWillPop: () {
        return _future(currentBackPressTime);
      },
      child: BlocBuilder<DeviceBloc, List<String>>(
        builder: (buildContext, result) {
          if (result.isNotEmpty) {
            String model = result[0];
            String uniqueNum = result[1];
            String phoneNum = result[2];
            String BASE_URL = "http://mtecsoft.co.kr:5800/pms/mobile/HpCheck.do?hpAuthNum=$phoneNum&model=$model&uniqueNum=$uniqueNum";
            _setController(BASE_URL);

            return WebViewWidget(controller: _controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _setController(String BASE_URL) {
    Uri url = Uri.parse(BASE_URL);

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress < 100) {
              const CircularProgressIndicator();
            }
          },
          // onPageStarted: (String url) {
          // },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains("tel:")) {
              await launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            } else if (request.url.contains("mailto:")) {
              await launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            } else if (request.url.contains("sms:")) {
              await launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(url);
  }
}
