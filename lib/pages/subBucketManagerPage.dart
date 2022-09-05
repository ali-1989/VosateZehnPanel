import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/models/BucketModel.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/subBuketModel.dart';
import 'package:app/pages/addContainerPage.dart';
import 'package:app/pages/addMediaPage.dart';
import 'package:app/pages/addMultiMediaPage.dart';
import 'package:app/pages/sortListItemsPage.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';

class SubBuketManagerPageInjectData {
  late BucketModel bucket;
}
///----------------------------------------------------------------
class SubBuketManagerPage extends StatefulWidget {
  static final route = GoRoute(
    path: 'SubBuketManagerPage',
    name: (SubBuketManagerPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => SubBuketManagerPage(injectData: state.extra as SubBuketManagerPageInjectData?),
  );

  final SubBuketManagerPageInjectData? injectData;

  const SubBuketManagerPage({
    Key? key,
    this.injectData,
  }) : super(key: key);

  @override
  State<SubBuketManagerPage> createState() => _SubBuketManagerPageState();
}
///============================================================================================
class _SubBuketManagerPageState extends StateBase<SubBuketManagerPage> {
  late Requester requester = Requester();
  late BucketModel bucketModel;
  List<SubBucketModel> subBucketList = [];
  bool isInLoadData = true;
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: onAddMedia,
                              child: Text('اضافه کردن مدیا')
                          ),

                          SizedBox(width: 15,),
                          ElevatedButton(
                              onPressed: onAddMultiMedia,
                              child: Text(' اضافه کردن مجموعه')
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 15,),
                  Text('محتوا ها'),

                  SizedBox(height: 10,),

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

    return SizedBox(
      key: ValueKey(itm.id),
      height: 80,
      child: InkWell(
        onTap: (){
          gotoEditePage(itm);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Builder(
                    builder: (ctx){
                      if(itm.imageModel != null){
                        return Image.network(itm.imageModel!.url!, width: 85, fit: BoxFit.fill,);
                      }

                      return Image.asset(AppImages.appIcon, width: 85, fit: BoxFit.fill);
                    },
                  ),
                ),

                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itm.title).bold(),

                      SizedBox(height: 5),
                      Flexible(
                          child: Text(itm.description?? '').alpha()
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12,),
                Builder(
                    builder: (ctx){
                      if(itm.type == SubBucketTypes.list.id()) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //if((itm.contentModel?.mediaIds.length?? 0) > 1)
                              IconButton(
                                  visualDensity: VisualDensity.compact,
                                  constraints: BoxConstraints.tightFor(),
                                  padding: EdgeInsets.zero,
                                  splashRadius: 18,
                                  onPressed: (){
                                    gotoSortPage(itm);
                                  },
                                  icon: Icon(AppIcons.sort, color: Colors.deepOrange, size: 20)
                              ),

                            IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: BoxConstraints.tightFor(),
                                padding: EdgeInsets.zero,
                                splashRadius: 18,
                                onPressed: (){
                                  gotoAddMultiMediaPage(itm);
                                },
                                icon: Icon(AppIcons.grid, color: Colors.blueAccent, size: 20,)
                            ),
                          ],
                        );
                      }

                      return SizedBox();
                    }
                ),

                SizedBox(width: 12,),

                if(itm.type != SubBucketTypes.list.id())
                  Icon(itm.getTypeIcon(), color: Colors.green, size: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void gotoEditePage(SubBucketModel sub) async {
    dynamic result;

    if(sub.type == SubBucketTypes.list.id()){
      final inject = AddContainerPageInjectData();
      inject.bucketModel = bucketModel;
      inject.subBucketModel = sub;

      result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx){
            return AddContainerPage(injectData: inject);
          }
      );
    }
    else {
      final inject = AddMediaPageInjectData();
      inject.bucketModel = bucketModel;
      inject.subBucketModel = sub;

      result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx){
            return AddMediaPage(injectData: inject);
          }
      );
    }

    if(result != null && result){
      isInLoadData = true;
      requestSubBucket();
    }
  }

  void gotoAddMultiMediaPage(SubBucketModel sub) async {
    final inject = AddMultiMediaPageInjectData();
    inject.bucketModel = bucketModel;
    inject.subBucketModel = sub;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddMultiMediaPage(injectData: inject);
        }
    );
  }

  void gotoSortPage(SubBucketModel sub) async {
    final inject = SortListItemsPageInjectData();
    inject.bucketModel = bucketModel;
    inject.subBucketModel = sub;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return SortListItemsPage(injectData: inject);
        }
    );
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

    if(result != null && result){
      isInLoadData = true;
      requestSubBucket();
    }
  }

  void onAddMultiMedia() async {
    final inject = AddContainerPageInjectData();
    inject.bucketModel = bucketModel;

    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddContainerPage(injectData: inject);
        }
    );

    if(result != null && result){
      isInLoadData = true;
      requestSubBucket();
    }
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void tryClick(){
    requestSubBucket();
    assistCtr.updateMain();
  }

  void requestSubBucket(){
    subBucketList.clear();

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
        b.imageModel = MediaManager.getById(b.coverId);
        b.mediaModel = MediaManager.getById(b.mediaId);

        subBucketList.add(b);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
