import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';

import 'package:app/pages/splash_page.dart';
import 'package:app/tools/app/appThemes.dart';

class AppBroadcast {
  AppBroadcast._();

  static final StreamController<bool> viewUpdaterStream = StreamController<bool>();
  static final RefreshController drawerMenuRefresher = RefreshController();
  static final NotifyBroadcast avatarNotifier = NotifyBroadcast();
  //---------------------- keys
  static LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorStateKey = GlobalKey<NavigatorState>();
  //static final layoutPageKey = GlobalKey<LayoutPageState>();

  //static final homePageBadges = <int, int>{};
  static bool isNetConnected = true;
  static bool isWsConnected = false;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildMaterialBySetTheme() {
    AppThemes.applyTheme(AppThemes.instance.currentTheme);
    reBuildMaterial();
  }

  static void reBuildMaterial() {
    if(kIsWeb){
      materialAppKey = UniqueKey();
    }

    viewUpdaterStream.sink.add(true);
  }

  static void gotoSplash(int waitingInSplashMil) {
    isInSplashTimer = true;
    splashWaitingMil = waitingInSplashMil;
    reBuildMaterial();
  }
}
