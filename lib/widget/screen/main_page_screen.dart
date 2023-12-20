import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: DeviceInfo()),
          ],
        ),
      ),
    );
  }
}

class DeviceInfo extends DefaultBody {
  DeviceInfo({Key? key}) : super(key: key);

  late DeviceBloc deviceBloc;
  late WebViewController _controller;
  late String BASE_URL;

  @override
  void onStart(Duration timeStamp) async {
    await getInfo();
    setController();
  }

   getInfo() {
    deviceBloc = buildContext.read<DeviceBloc>();
    deviceBloc.getDeviceInfo();
  }

  void setController() {
    Uri url = Uri.parse(BASE_URL);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            AppUtil.printHighlightLog(request.url);
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

  @override
  Widget buildBody(BuildContext context) {
    return BlocBuilder<DeviceBloc, List<String>>(
        builder: (buildContext, result) {
      if (result.isNotEmpty) {
        String model = result[0];
        String uniqueNum = result[1];
        String phoneNum = result[2];
        BASE_URL = "http://mtecsoft.co.kr:5800/pms/mobile/HpCheck.do?hpAuthNum=$phoneNum&model=$model&uniqueNum=$uniqueNum";
        return WebViewWidget(
          controller: _controller,
        );
      } else {
        return Center(child: Text("이동중"));
      }
    });
  }
}
