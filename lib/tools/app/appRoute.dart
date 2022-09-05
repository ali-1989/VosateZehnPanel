import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:app/pages/aboutUsPage.dart';
import 'package:app/pages/advertisingManagerPage.dart';
import 'package:app/pages/aidDialogPage.dart';
import 'package:app/pages/aidPage.dart';
import 'package:app/pages/contentManagerPage.dart';
import 'package:app/pages/dailyTextPage.dart';
import 'package:app/pages/e404_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/speakersManagerPage.dart';
import 'package:app/pages/termPage.dart';
import 'package:app/pages/ticketManagerPage.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appNavigator.dart';

class AppRoute {
  static final List<GoRoute> freeRoutes = [];

  AppRoute._();

  static late BuildContext materialContext;

  static BuildContext getContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= WidgetsBinding.instance.focusManager.primaryFocus?.context; //deep: 71

    return res?? materialContext;
  }

  static Future<bool> saveRouteName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchRouteScreenName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }

  static void backRoute() {
    final mustLastCtx = AppNavigator.getLastRouteContext(getContext());
    AppNavigator.backRoute(mustLastCtx);
  }

  static void backToRoot(BuildContext context) {
    //AppNavigator.popRoutesUntilRoot(AppRoute.getContext());

    while(canPop(context)){
      pop(context);
    }
  }

  static bool canPop(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  static void pop(BuildContext context) {
    GoRouter.of(context).pop();
  }

  static void push(BuildContext context, String address, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).go(address, extra: extra);
    }
    else {
      GoRouter.of(context).push(address, extra: extra);
    }
  }

  static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).goNamed(name, params: {}, extra: extra);
    }
    else {
      GoRouter.of(context).pushNamed(name, params: {}, extra: extra);
    }
  }

  static void replaceNamed(BuildContext context, String name, {dynamic extra}) {
    GoRouter.of(context).replaceNamed(name, params: {}, extra: extra);
  }

  static void init(){
    freeRoutes.add(LoginPage.route);
  }
}
///============================================================================================
final mainRouter = GoRouter(
    routes: <GoRoute>[
      HomePage.route,
    ],
    initialLocation: HomePage.route.path,
    routerNeglect: true,//In browser 'back' button not work
    errorBuilder: routeErrorHandler,
    redirect: _mainRedirect,
);

final homeRouter = <GoRoute>[
  LoginPage.route,
  AboutUsPage.route,
  AidPage.route,
  TermPage.route,
  AidDialogPage.route,
  ContentManagerPage.route,
  SpeakersManagerPage.route,
  TicketManagerPage.route,
  AdvertisingManagerPage.route,
  DailyTextPage.route,
  ];

bool checkFreeRoute(GoRoute route, GoRouterState state){
  final routeIsTop = route.path.startsWith('/');
  final stateIsTop = state.subloc.startsWith('/');

  if((routeIsTop && stateIsTop) || (!routeIsTop && !stateIsTop)){
    return route.path == state.subloc;
  }

  if(!routeIsTop){
    //return '${HomePage.route.path}/${route.path}' == state.subloc;  if homePage is not backSlash, like:/admin
    return '/${route.path}' == state.subloc;
  }

  return false;
}

String? _mainRedirect(GoRouterState state){

  /*if(state.subloc == HomePage.route.path){
  }*/

  if(!Session.hasAnyLogin()){
    if(AppRoute.freeRoutes.any((r) => checkFreeRoute(r, state))){
      return null;
    }
    else {
      final from = state.subloc == '/' ? '' : '?gt=${state.location}';
      return '/${LoginPage.route.path}$from'.replaceFirst('//', '/');
    }
  }

  return state.queryParams['gt'];
}

Widget routeErrorHandler(BuildContext context, GoRouterState state) {
  /*final split = state.subloc.split('/');
  final count = state.subloc.startsWith('/')? 1 : 0;

  if(split.length > count){
    AppRoute.pushNamed(AppRoute.getContext(), state.subloc.substring(0, state.subloc.lastIndexOf('/')));
    return SizedBox();
  }*/

 return const E404Page();
}
///============================================================================================
class MyPageRoute extends PageRouteBuilder {
  final Widget widget;
  final String? routeName;

  MyPageRoute({
    required this.widget,
    this.routeName,
  })
      : super(
        settings: RouteSettings(name: routeName),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return widget;
        },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        //ScaleTransition, RotationTransition, SizeTransition, FadeTransition
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
