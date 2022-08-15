import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:vosate_zehn_panel/pages/aboutUsPage.dart';
import 'package:vosate_zehn_panel/pages/aidDialogPage.dart';
import 'package:vosate_zehn_panel/pages/aidPage.dart';
import 'package:vosate_zehn_panel/pages/contentManagerPage.dart';
import 'package:vosate_zehn_panel/pages/termPage.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appIcons.dart';
import 'package:vosate_zehn_panel/tools/app/appMessages.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';

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

  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppMessages.adminPageTitle),
          ),
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

          return GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 170,
                mainAxisExtent: 120,
              //childAspectRatio: 1
            ),
            children: [
              buildItem('مدیریت "درباره ما"', AppIcons.lightBulb, gotoAboutUsPage),
              buildItem('مدیریت "حفظ حریم"', AppIcons.lock, gotoTermPage),
              buildItem('مدیریت "حمایت از ما"', AppIcons.cashMultiple, gotoAidPage),
              buildItem('متن "دیالوگ حمایت"', AppIcons.cashMultiple, gotoAidDialogPage),
              buildItem('مدیریت محتوا', AppIcons.apps, gotoContentManagerPage),
              buildItem('گویندگان', AppIcons.accountDoubleCircle, gotoAidDialogPage),
              buildItem('نمایش ارتباط باما', AppIcons.email, gotoAidDialogPage),
              buildItem('مدیریت تبلیغات', AppIcons.picture, gotoAidDialogPage),
              buildItem('مدیریت جملات روز', AppIcons.message, gotoAidDialogPage),
            ],
          );
        }
    );
  }

  Widget buildItem(String title, IconData icon, VoidCallback onTap){
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              Expanded(child: SizedBox(),),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  void gotoAboutUsPage(){
    AppRoute.pushNamed(context, AboutUsPage.route.name!);
  }

  void gotoAidPage(){
    AppRoute.pushNamed(context, AidPage.route.name!);
  }

  void gotoTermPage(){
    AppRoute.pushNamed(context, TermPage.route.name!);
  }

  void gotoAidDialogPage(){
    AppRoute.pushNamed(context, AidDialogPage.route.name!);
  }

  void gotoContentManagerPage(){
    AppRoute.pushNamed(context, ContentManagerPage.route.name!);
  }
}
