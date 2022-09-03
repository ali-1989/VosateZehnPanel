import 'package:app/pages/advertisingManagerPage.dart';
import 'package:app/pages/ticketManagerPage.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/pages/aboutUsPage.dart';
import 'package:app/pages/aidDialogPage.dart';
import 'package:app/pages/aidPage.dart';
import 'package:app/pages/contentManagerPage.dart';
import 'package:app/pages/empty.dart';
import 'package:app/pages/speakersManagerPage.dart';
import 'package:app/pages/termPage.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';

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
              buildItem('مدیریت \n"درباره ما"', AppIcons.lightBulb, gotoAboutUsPage),
              buildItem('مدیریت \n"حفظ حریم"', AppIcons.lock, gotoTermPage),
              buildItem('مدیریت \n"حمایت از ما"', AppIcons.cashMultiple, gotoAidPage),
              buildItem('متن \n"دیالوگ حمایت"', AppIcons.cashMultiple, gotoAidDialogPage),
              buildItem('مدیریت محتوا', AppIcons.apps, gotoContentManagerPage),
              buildItem('گویندگان', AppIcons.accountDoubleCircle, gotoSpeakerPage),
              buildItem('نمایش ارتباط باما', AppIcons.email, gotoTicketPage),
              buildItem('مدیریت تبلیغات', AppIcons.picture, gotoAdvertisingPage),
              buildItem('مدیریت جملات روز', AppIcons.message, gotoEmptyPage),
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

  void gotoSpeakerPage(){
    AppRoute.pushNamed(context, SpeakersManagerPage.route.name!);
  }

  void gotoTicketPage(){
    AppRoute.pushNamed(context, TicketManagerPage.route.name!);
  }

  void gotoAdvertisingPage(){
    AppRoute.pushNamed(context, AdvertisingManagerPage.route.name!);
  }

  void gotoEmptyPage(){
    AppRoute.pushNamed(context, Empty.route.name!);
  }
}
