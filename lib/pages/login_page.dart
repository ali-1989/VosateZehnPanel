import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:vosate_zehn_panel/pages/home_page.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appImages.dart';
import 'package:vosate_zehn_panel/tools/app/appMessages.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/tools/app/appThemes.dart';

class LoginPage extends StatefulWidget {
  static final route = GoRoute(
    path: 'login',
    name: (LoginPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const LoginPage(),
  );

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
///=================================================================================================
class _LoginPageState extends StateBase<LoginPage> {
  TextEditingController userNameCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  late InputDecoration inputDecoration;
  late Requester requester;

  @override
  void initState(){
    super.initState();

    requester = Requester();

    inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
    );
  }

  @override
  void dispose() {
    userNameCtr.dispose();
    passwordCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return MaxWidth(
          maxWidth: 300,
          child: Scaffold(
            backgroundColor: AppThemes.instance.currentTheme.primaryColor,
            body: SafeArea(
                child: buildBody()
            ),
          ),
        );
      }
    );
  }

  Widget buildBody(){
    return ListView(
      children: [
        SizedBox(
          height: MathHelper.percent(MediaQuery.of(context).size.height, 30),
          child: Center(
            child: Image.asset(AppImages.appIcon, width: 100, height: 100,),
          ),
        ),

        const SizedBox(height: 50,),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              TextField(
                controller: userNameCtr,
                decoration: inputDecoration.copyWith(
                  hintText: AppMessages.userName,
                  labelText: AppMessages.userName,
                ),
              ),

              const SizedBox(height: 10,),
              TextField(
                controller: passwordCtr,
                decoration: inputDecoration.copyWith(
                    hintText: AppMessages.password,
                  labelText: AppMessages.password,
                ),
              ),

              const SizedBox(height: 10,),

              SizedBox(
                child: ElevatedButton(
                    onPressed: loginCall,
                    child: const Text('ورود')
                ),
              ),
            ],
          ),
          ),
      ],
    );
  }

  void loginCall(){
    final userName = userNameCtr.text.trim();
    final password = passwordCtr.text.trim();

    if(userName.isEmpty || password.isEmpty){
      AppSheet.showSheetOk(context, 'لطفا گزینه ها را پر کنید');
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'login_admin';
    js[Keys.userName] = userName;
    js[Keys.password] = password;

    requester.prepareUrl();
    requester.bodyJson = js;
    requester.debug = true;

    requester.httpRequestEvents.onAnyState = (req) async {
      //hideLoading();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final userModel = await Session.login$newProfileData(data);

      if(userModel != null) {
        AppRoute.push(context, HomePage.route.path);
      }
      else {
        AppSheet.showSheet$OperationFailed(context);
      }
    };

    //showLoading();
    requester.request(context);
  }
}
