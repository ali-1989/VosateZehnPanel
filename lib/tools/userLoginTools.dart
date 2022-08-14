import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:vosate_zehn_panel/managers/settingsManager.dart';
import 'package:vosate_zehn_panel/models/userModel.dart';
import 'package:vosate_zehn_panel/pages/login_page.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/tools/app/appBroadcast.dart';
import 'package:vosate_zehn_panel/tools/app/appHttpDio.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import '/system/keys.dart';
import '/tools/app/appManager.dart';

class UserLoginTools {
  UserLoginTools._();

  static void onLogin(UserModel user){
  }

  static void onLogoff(UserModel user){
    sendLogoffState(user);
  }

  // on new data for existUser
  static void onProfileChange(UserModel user, Map? old) async {
  }

  static void sendLogoffState(UserModel user){
    if(AppBroadcast.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs[Keys.requestZone] = 'Logoff_user_report';
      reqJs[Keys.requesterId] = user.userId;
      reqJs[Keys.forUserId] = user.userId;

      AppManager.addAppInfo(reqJs, curUser: user);

      final info = HttpItem();
      info.fullUrl = '${SettingsManager.settingsModel.httpAddress}/graph-v1';
      info.method = 'POST';
      info.body = JsonHelper.mapToJson(reqJs);
      info.setResponseIsPlain();

      AppHttpDio.send(info);
    }
  }

  static Future forceLogoff(String userId) async {
    final isCurrent = Session.getLastLoginUser()?.userId == userId;
    await Session.logoff(userId);

    if (isCurrent) {
      AppRoute.backToRoot(AppRoute.getContext());

      Future.delayed(Duration(milliseconds: 400), (){
        AppRoute.replaceNamed(AppRoute.getContext(), LoginPage.route.name!);
      });
    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();

    AppRoute.backToRoot(AppRoute.getContext());
  }


}
