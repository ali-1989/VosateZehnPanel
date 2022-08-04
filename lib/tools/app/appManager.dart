import 'package:flutter/material.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';

import 'package:vosate_zehn_panel/constants.dart';
import 'package:vosate_zehn_panel/models/userModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/deviceInfoTools.dart';

class AppManager {
  AppManager._();

  static late Logger logger;
  static late Reporter reporter;

  // postCallback work only inside build()
  static late WidgetsBinding widgetsBinding;

  static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? AppRoute.getContext());

    return src;
  }

  static Map addAppInfo(Map src, {UserModel? curUser}) {
    final token = curUser?.token ?? Session.getLastLoginUser()?.token;

    src.addAll(getAppInfo(token?.token));

    return src;
  }

  static Map<String, dynamic> getAppInfo(String? token) {
    final res = <String, dynamic>{};
    res[Keys.deviceId] = DeviceInfoTools.deviceId;
    res[Keys.appName] = Constants.appName;
    res['app_version_code'] = Constants.appVersionCode;
    res['app_version_name'] = Constants.appVersionName;

    if (token != null) {
      res['token'] = token;
    }

    return res;
  }

  static WidgetsBinding getAppWidgetsBinding() {
    return widgetsBinding;
  }
}
