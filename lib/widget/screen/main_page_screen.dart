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
  _Body({Key? key}) : super(key: key);

  @override
  Widget buildBody(BuildContext context) {
    WebViewController webViewController = WebViewController();

    return SafeArea(
      child: Scaffold(
        floatingActionButton: floatBackButton(webViewController),
        body: Column(
          children: [
            Expanded(child: DeviceInfo(webViewController)),
          ],
        ),
      ),
    );
  }

  Widget floatBackButton(WebViewController webViewController) {
    if (Platform.isIOS) {
      return FloatingActionButton(
        child: const Icon(Icons.keyboard_backspace_rounded),
        onPressed: () {
          _moveToBackPage(webViewController);
        },
      );
    } else {
      return Container();
    }
  }

  DateTime? currentBackPressTime;

  void _moveToBackPage(WebViewController _controller) async {
    DateTime now = DateTime.now();

    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      if (currentBackPressTime != null) {
        if (now.difference(currentBackPressTime!) < Duration(seconds: 2)) {
          exit(0);
        } else {
          showToastMessage();
          currentBackPressTime = now;
        }
      } else {
        showToastMessage();
        currentBackPressTime = now;
      }
    }
  }

  Future<bool?> showToastMessage() {
    String morePressButton = "뒤로가기 버튼을 한번 더 누르면 종료됩니다";
    return Fluttertoast.showToast(
        msg: morePressButton,
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_SHORT,);
  }
}

class DeviceInfo extends DefaultBody {
  WebViewController webViewController;

  DeviceInfo(this.webViewController, {Key? key}) : super(key: key);

  DateTime? currentBackPressTime;
  late DeviceBloc deviceBloc;

  @override
  void onStart(Duration timeStamp) {
    _getPhoneInfo();
  }

  void _getPhoneInfo() {
    deviceBloc = buildContext.read<DeviceBloc>();
    deviceBloc.getDeviceInfo();
  }

  Future<bool> pressBackButton() async {
    DateTime now = DateTime.now();

    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future(() => false);
    } else {
      if (currentBackPressTime != null) {
        if (now.difference(currentBackPressTime!) < const Duration(seconds: 2)) {
          return Future(() => true);
        } else {
          showToastMessage();
          currentBackPressTime = now;
          return Future(() => false);
        }
      } else {
        showToastMessage();
        currentBackPressTime = now;
        return Future(() => false);
      }
    }
  }

  Future<bool?> showToastMessage() {
    String morePressButton = "뒤로가기 버튼을 한번 더 누르면 종료됩니다";
    return Fluttertoast.showToast(
        msg: morePressButton,
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget buildBody(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        return pressBackButton();
      },
      child: BlocBuilder<DeviceBloc, List<String>>(
        builder: (buildContext, result) {
          if (result.isNotEmpty) {
            String model = result[0];
            String uniqueNum = result[1];
            String phoneNum = result[2];
            String BASE_URL = "http://mtecsoft.co.kr:5800/pms/mobile/HpCheck.do?hpAuthNum=$phoneNum&model=$model&uniqueNum=$uniqueNum";
            _setController(BASE_URL);

            return WebViewWidget(controller: webViewController);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _setController(String BASE_URL) {
    Uri url = Uri.parse(BASE_URL);

    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress < 100) {
              const CircularProgressIndicator();
            }
          },
          // onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            Fluttertoast.showToast(msg: error.description);
          },
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
