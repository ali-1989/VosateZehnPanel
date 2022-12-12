import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/deviceInfoTools.dart';

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
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return MaxWidth(
          maxWidth: 400,
          child: Scaffold(
            //backgroundColor: AppThemes.instance.currentTheme.primaryColor,
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

              const SizedBox(height: 50,),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: loginCall,
                    child: Text(AppMessages.loginBtn)
                ),
              ),
            ],
          ),
          ),
      ],
    );
  }

  void loginCall() async {
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
    js.addAll(DeviceInfoTools.getDeviceInfo());

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
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

    showLoading();
    requester.request(context);
  }
}
