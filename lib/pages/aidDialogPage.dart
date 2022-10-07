import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/notFetchData.dart';

class AidDialogPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'aid_dialog',
      name: (AidDialogPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => const AidDialogPage(),
  );

  const AidDialogPage({Key? key}) : super(key: key);

  @override
  State<AidDialogPage> createState() => _AidDialogPageState();
}
///============================================================================================
class _AidDialogPageState extends StateBase<AidDialogPage> {
  TextEditingController textCtr = TextEditingController();
  late Requester requester = Requester();
  bool isInLoadData = false;
  String? text;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestGetAid();
  }

  @override
  void dispose() {
    requester.dispose();
    textCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, controller, sendData) {
        return Scaffold(
          appBar: AppBar(
            title: Text(' پاپ اپ حمایت از ما'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  Widget buildBody(){
    if(isInLoadData){
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if(!assistCtr.hasState(state$fetchData)){
      return NotFetchData(tryClick: tryClick,);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('متن پاپ اپ حمایت از ما').bold(),

          SizedBox(height: 20),

          Flexible(
            child: TextField(
              minLines: 6,
              maxLines: 10,
              controller: textCtr,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            )
          ),

          SizedBox(height: 20),

          ElevatedButton(
              onPressed: onSaveCall,
              child: Text('ذخیره')
          ),

        ],
      ),
    );
  }

  void injectDataToEditor(String data) async {
    textCtr.text = data;
  }

  Future<String?> getEditorData() async {
    return textCtr.text;
  }

  void onSaveCall() async {
    final res = await getEditorData();

    if(res != null) {
      requestSetAid(res);
    }
    else {
      AppSheet.showSheet$OperationCannotBePerformed(context);
    }
  }

  void tryClick(){
    requestGetAid();
    assistCtr.updateMain();
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    callState();
  }

  void requestGetAid(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_aid_dialog_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      text = data[Keys.data];

      injectDataToEditor(text?? '');

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context);
  }

  void requestSetAid(String data){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_aid_dialog_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.data] = data;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context);
    };

    showLoading();
    requester.request(context);
  }
}
