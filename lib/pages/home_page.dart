import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn_panel/pages/login_page.dart';

import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appDialogIris.dart';
import 'package:vosate_zehn_panel/tools/app/appLoading.dart';
import 'package:vosate_zehn_panel/tools/app/appOverlay.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/tools/app/appSnack.dart';
import 'package:vosate_zehn_panel/tools/app/appToast.dart';

class HomePage extends StatefulWidget {
  static final route = GoRoute(
    path: '/',
    name: (HomePage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const HomePage(),
    routes: homeRouter
  );

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
///=================================================================================================
class _HomePageState extends StateBase<HomePage> {
  int selectedItem = 0;
  var tt = 'hi ali isjl ghgh gghgh gghgh 555555 ghghgh ghgg gghgh 555555 ghghgh ghgg g ghghh ghghgh ghgh sdsds dds';

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
              child: buildBody()
          ),
        );
      }
    );
  }

  Widget buildBody(){
    return Builder(
        builder: (ctx){
          /*if(assistCtr.hasState(AssistController.state$normal)){

          }*/

          return PageView(
            children: [
              buildP1(),
              Text('p2'),
            ],
          );
        }
    );
  }

  Widget buildP1(){
    return Column(
      children: [
        ElevatedButton(onPressed: showLoad,
            child: Text('loading')
        ),

        ElevatedButton(onPressed: showDialog,
            child: Text('dialog')
        ),

        ElevatedButton(onPressed: showSheet,
            child: Text('sheet')
        ),

        ElevatedButton(onPressed: showToast,
            child: Text('toast')
        ),

        ElevatedButton(onPressed: showSnack,
            child: Text('snack')
        ),
      ],
    );
  }

  void showLoad(){
    //AppLoading.instance.showWaiting(context);
    showLoading();

    Future.delayed(Duration(seconds: 3), (){
      AppOverlay.hideScreen(context);
    });
  }

  void showToast(){
    AppRoute.pushNamed(context, LoginPage.route.path);
  }

  void showSheet(){
    AppSheet.showSheetOk(context, tt);
    //AppSheet.showSheetDialog(context, message: tt);
  }

  void showSnack(){
    AppSnack.showInfo(context, tt);
  }

  void showDialog(){
    AppDialogIris.instance.showInfoDialog(context, null, tt);
  }
}
