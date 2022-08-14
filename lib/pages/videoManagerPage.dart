import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:vosate_zehn_panel/pages/videoAddPage.dart';

import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/views/notFetchData.dart';

class VideoManagerPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'VideoManager',
      name: (VideoManagerPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => const VideoManagerPage(),
  );

  const VideoManagerPage({Key? key}) : super(key: key);

  @override
  State<VideoManagerPage> createState() => _VideoManagerPageState();
}
///============================================================================================
class _VideoManagerPageState extends StateBase<VideoManagerPage> {
  late Requester requester = Requester();
  bool isInLoadData = false;
  int allCount = 0;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestVideoBucket();
  }

  @override
  void dispose() {
    requester.dispose();

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
            title: Text('مدیریت بخش فیلم ها'),
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
            Row(
              children: [
                ElevatedButton(onPressed: (){}, child: Text('مورد جدید +')),

                SizedBox(width: 20,),
                Text('تعداد کل: $allCount').bold(),
              ],
            ),

            SizedBox(height: 5,),

            Expanded(
              child: ListView.builder(
                itemCount: 30,
                //physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (ctx, idx){
                  return ColoredBox(
                    color: ColorHelper.getRandomRGB(),
                      child: SizedBox(height: 20,));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void gotoAddPage() async {
    AppRoute.pushNamed(context, VideoAddPage.route.name!);
    GoRouter.of(context).addListener(() {print('llllllllllll');});
  }

  void tryClick(){
    requestVideoBucket();
    assistCtr.updateMain();
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void requestVideoBucket(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_video_bucket_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req) async {
      //assistCtr.removeStateAndUpdate(state$fetchData);
      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      //text = data[Keys.data];

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
