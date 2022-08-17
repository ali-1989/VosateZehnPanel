import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:vosate_zehn_panel/managers/mediaManager.dart';

import 'package:vosate_zehn_panel/models/BucketModel.dart';
import 'package:vosate_zehn_panel/models/subBuketModel.dart';
import 'package:vosate_zehn_panel/pages/addMediaPage.dart';
import 'package:vosate_zehn_panel/pages/contentManagerPage.dart';
import 'package:vosate_zehn_panel/services/pagesEventBus.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appImages.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/views/emptyData.dart';
import 'package:vosate_zehn_panel/views/notFetchData.dart';

class BuketMediaManagerPageInjectData {
  late BucketModel bucket;
}
///----------------------------------------------------------------
class BuketMediaManagerPage extends StatefulWidget {
  static final route = GoRoute(
    path: 'BuketMediaManagerPage',
    name: (BuketMediaManagerPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => BuketMediaManagerPage(injectData: state.extra as BuketMediaManagerPageInjectData?),
  );

  final BuketMediaManagerPageInjectData? injectData;

  const BuketMediaManagerPage({
    Key? key,
    this.injectData,
  }) : super(key: key);

  @override
  State<BuketMediaManagerPage> createState() => _BuketMediaManagerPageState();
}
///============================================================================================
class _BuketMediaManagerPageState extends StateBase<BuketMediaManagerPage> {
  late Requester requester = Requester();
  late BucketModel bucketModel;
  List<SubBucketModel> subBucketList = [];
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    if(widget.injectData == null) {
      addPostOrCall(() => AppRoute.pop(context));
    }
    else {
      bucketModel = widget.injectData!.bucket;
      requestSubBucket();
    }
  }

  @override
  void dispose() {
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.injectData == null){
      return SizedBox();
    }

    return Assist(
      controller: assistCtr,
      builder: (context, controller, sendData) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text('مدیریت رسانه ها'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  Widget buildBody(){
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        child: MaxWidth(
          maxWidth: 500,
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Builder(
                            builder: (ctx){
                              if(bucketModel.imageModel != null){
                                return Image.network(bucketModel.imageModel!.url!, width: 110, fit: BoxFit.fill,);
                              }

                              return Image.asset(AppImages.appIcon, width: 85, fit: BoxFit.fill);
                            },
                          ),
                        ),

                        SizedBox(height: 8,),
                        Text(bucketModel.title).bold(),

                        SizedBox(height: 5),
                        Text(bucketModel.description?? '').alpha(),
                      ],
                    ),
                  ),

                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 5,
                        width: double.infinity,
                        child: ColoredBox(
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('محتوا'),

                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: onAddMedia,
                              child: Text('اضافه کردن')
                          ),

                          SizedBox(width: 10,),
                          ElevatedButton(
                              onPressed: onMultiMedia,
                              child: Text(' اضافه کردن مجموعه')
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20,),

                  LayoutBuilder(
                      builder: (ctx, siz) {
                        if(isInLoadData){
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if(!assistCtr.hasState(state$fetchData)){
                          return SizedBox(
                              height: 200,
                              child: Center(child: NotFetchData(tryClick: tryClick,))
                          );
                        }

                        if(subBucketList.isEmpty){
                          return SizedBox(
                              height: 200,
                              child: Center(child: EmptyData())
                          );
                        }

                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: subBucketList.length,
                                itemBuilder: (ctx, idx){
                                  return buildListItem(idx);
                                }
                            )
                        ).wrapBoxBorder();
                      }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListItem(int idx) {
    final itm = subBucketList[idx];

    return ColoredBox(color: ColorHelper.getRandomRGB(),
        child: SizedBox(height: 20,));
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void tryClick(){
    requestSubBucket();
    assistCtr.updateMain();
  }

  void onAddMedia() async {
    final inject = AddMediaPageInjectData();
    inject.bucketModel = bucketModel;

    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddMediaPage(injectData: inject);
        }
    );

    print('666666666666666666666666');
    print(result);

    if(result){
      isInLoadData = true;
      requestSubBucket();
    }
  }

  void onMultiMedia() async {

  }

  void requestDeleteMedia(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_bucket_image';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = bucketModel.id;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      bucketModel.imageModel = null;

      assistCtr.updateMain();
      PagesEventBus.getEventBus((ContentManagerPage).toString()).callEvent('update', null);
    };

    showLoading();
    requester.request(context);
  }

  void requestSubBucket(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_sub_bucket_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = bucketModel.id;


    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final dList = data['sub_bucket_list'];
      final mList = data['media_list'];

      MediaManager.addItemsFromMap(mList);

      for(final k in dList){
        final b = SubBucketModel.fromMap(k);
        b.imageModel = MediaManager.getById(b.mediaId);

        subBucketList.add(b);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
