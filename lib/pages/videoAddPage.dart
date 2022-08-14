import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/searchBar.dart';

import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/views/notFetchData.dart';

class VideoAddPageInjectData {

}
///----------------------------------------------------------------
class VideoAddPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'VideoAdd',
      name: (VideoAddPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => VideoAddPage(injectData: state.extra as VideoAddPageInjectData),
  );

  final VideoAddPageInjectData injectData;

  const VideoAddPage({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<VideoAddPage> createState() => _VideoAddPageState();
}
///============================================================================================
class _VideoAddPageState extends StateBase<VideoAddPage> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  late Requester requester = Requester();

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    requester.dispose();
    titleCtr.dispose();
    descriptionCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, controller, sendData) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text('مدیریت فیلم'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  Widget buildBody(){
    return MaxWidth(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(

            ),

            SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }

  void onSaveCall() async {

  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
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
