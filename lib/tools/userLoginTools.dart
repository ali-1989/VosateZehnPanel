import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appRoute.dart';

class UserLoginTools {
  UserLoginTools._();

  static void init(){
    Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);
  }

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

      PublicAccess.addAppInfo(reqJs, curUser: user);

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

    if (isCurrent && AppRoute.materialContext != null) {
      AppRoute.backToRoot(AppRoute.getLastContext()!);

      Future.delayed(Duration(milliseconds: 400), (){
        AppRoute.replaceNamed(AppRoute.getLastContext()!, LoginPage.route.name!);
      });
    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();

    if (AppRoute.materialContext != null) {
      AppRoute.backToRoot(AppRoute.getLastContext()!);
    }
  }
}
