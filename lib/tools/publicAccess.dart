import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:vosate_zehn_panel/constants.dart';
import 'package:vosate_zehn_panel/managers/settingsManager.dart';
import 'package:vosate_zehn_panel/models/dateFieldMixin.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/deviceInfoTools.dart';

class PublicAccess {
  PublicAccess._();

  static String graphApi = '${SettingsManager.settingsModel.httpAddress}/graph-v1';
  static ClassicFooter classicFooter = ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );

  static UpperLower findUpperLower(List<DateFieldMixin> list, bool isAsc){
    final res = UpperLower();

    if(list.isEmpty){
      return res;
    }

    DateTime lower = list[0].date!;
    DateTime upper = list[0].date!;

    for(final x in list){
      var c = DateHelper.compareDates(x.date, lower, asc: isAsc);

      if(c < 0){
        lower = x.date!;
      }

      c = DateHelper.compareDates(x.date, upper, asc: isAsc);

      if(c > 0){
        upper = x.date!;
      }
    }

    return UpperLower()..lower = lower..upper = upper;
  }

  ///----------- HowIs ----------------------------------------------------
  static Map<String, dynamic> getHowIsMap() {
    final howIs = <String, dynamic>{
      'how_is': 'HowIs',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(AppRoute.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    howIs['users'] = users;

    return howIs;
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{
      'heart': 'Heart',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(AppRoute.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}

///===================================================================================
class UpperLower {
  DateTime? upper;
  DateTime? lower;
}
