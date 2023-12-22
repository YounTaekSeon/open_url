import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:open_url/utils/app_util.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceBloc extends Cubit<List<String>> {

  DeviceBloc() : super([]);
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String model = "";
  String uniqueNumber = "";
  String number = "";
  static const MethodChannel _channel = MethodChannel('mobile_number');
  late String simCardsJson;

  void getDeviceInfo() async {
    if (!await Permission.phone.request().isGranted) {
      Permission.values.where((permission) {
        return permission != Permission.phone;
      });
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      model = androidDeviceInfo.model;
      uniqueNumber = androidDeviceInfo.id;
      simCardsJson = await _channel.invokeMethod('getMobileNumber');

      final String? mobile = await MobileNumber.mobileNumber;

      if (mobile?.contains("+") ?? false) {
        mobile?.replaceAll("+", "");
      }
      number = mobile?.substring(2) ?? "";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      model = iosDeviceInfo.utsname.machine ?? "";
      uniqueNumber = iosDeviceInfo.identifierForVendor ?? "";
    } else {
      Fluttertoast.showToast(msg: "지원하지 않는 플랫폼입니다.");
    }

    AppUtil.printHighlightLog("model: $model, unique: $uniqueNumber, number: $number");
    emit([model, uniqueNumber, number]);
  }
}
