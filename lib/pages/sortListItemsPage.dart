import 'package:app/pages/mediaTitlePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/structures/models/BucketModel.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/contentModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';

class SortListItemsPageInjectData {
  late BucketModel bucketModel;
  late SubBucketModel subBucketModel;
}
///----------------------------------------------------------------
class SortListItemsPage extends StatefulWidget {
  final SortListItemsPageInjectData injectData;

  const SortListItemsPage({required this.injectData, Key? key}) : super(key: key);

  @override
  State<SortListItemsPage> createState() => _SortListItemsPageState();
}
///============================================================================================
class _SortListItemsPageState extends StateBase<SortListItemsPage> {
  late Requester requester = Requester();
  ScrollController scrollCtr = ScrollController();
  List<MediaModel> itemList = [];
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestData();
  }

  @override
  void dispose() {
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: MaxWidth(
        maxWidth: 500,
        child: Assist(
          controller: assistCtr,
          builder: (context, controller, sendData) {
            return Scaffold(
              body: buildBody(),
            );
          },
        ),
      ),
    );
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  Widget buildBody(){
    return Scrollbar(
      trackVisibility: true,
      thumbVisibility: true,
      controller: scrollCtr,
      child: SingleChildScrollView(
        controller: scrollCtr,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: ElevatedButton(
                      //style: ElevatedButton.styleFrom(primary: Colors.blue),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: Text('??????????')
                    ),
                  ),

                  SizedBox(width: 20),
                  SizedBox(
                    width: 110,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: onSaveClick,
                        child: Text('??????????')
                    ),
                  ),

                  SizedBox(width: 40),
                  Visibility(
                    visible: !isInLoadData && widget.injectData.subBucketModel.contentModel != null,
                      child: CheckBoxRow(
                        value: widget.injectData.subBucketModel.contentModel?.hasOrder,
                        description: Text('?????????? ???????????? ????????'),
                        onChanged: (value) {
                          widget.injectData.subBucketModel.contentModel!.hasOrder = !widget.injectData.subBucketModel.contentModel!.hasOrder;
                          assistCtr.updateMain();
                        },

                      )
                  ),
                ],
              ),

              SizedBox(height: 20),

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

                  if(itemList.isEmpty){
                    return SizedBox(
                      height: 200,
                        child: Center(child: EmptyData())
                    );
                  }

                  return Column(
                    children: [
                      Text('???????? ????????').bold(),

                      SizedBox(height: 20,),
                      ReorderableListView.builder(
                        onReorder: reorder,
                        shrinkWrap: true,
                        itemCount: itemList.length,
                        itemBuilder: (ctx, idx){
                          return buildListItem(idx);
                        },
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListItem(int idx){
    final itm = itemList[idx];

    return SizedBox(
      key: ValueKey(itm.id),
      height: 80,
      child: InkWell(
        onTap: (){
          //play(itm);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isVideo(itm)? AppIcons.videoCamera: AppIcons.headset
                ),

                SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: Text('${itm.fileName}',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),

                SizedBox(width: 5),
                Expanded(
                    child: GestureDetector(
                      onTap: (){
                        changeMediaTitle(itm);
                      },
                      child: Text(itm.title?? '[??????????]',
                      style: TextStyle(color: Colors.blue)),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void changeMediaTitle(MediaModel media) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return MediaTitlePage(injectData: MediaTitlePageInjectData()..mediaModel = media);
      }
    );

    assistCtr.updateMain();
  }

  void reorder(oldIndex, newIndex){
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }

    final item = itemList.removeAt(oldIndex);
    itemList.insert(newIndex, item);

    assistCtr.updateMain();
  }

  bool isVideo(MediaModel model){
    return (model.extension?? PathHelper.getDotExtension(model.fileName?? '')) == '.mp4';
  }

  void tryClick(){
    requestData();
    assistCtr.updateMain();
  }

  void onSaveClick(){
    requestSave();
  }

  void requestData(){
    itemList.clear();

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_content_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.subBucketModel.id;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final content = data['content'] as Map?;
      //final speaker = data['speaker'] as Map?;
      final mList = data['media_list'] as List?;

      MediaManager.addItemsFromMap(mList);

      final contentModel = ContentModel.fromMap(content);

      widget.injectData.subBucketModel.contentId = contentModel.id;
      widget.injectData.subBucketModel.contentModel = contentModel;

      for(final k in contentModel.mediaIds){
        final mm = MediaManager.getById(k);

        if(mm != null) {
          itemList.add(mm);
        }
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context, false);
  }

  void requestSave(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_bucket_content';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['sort_command'] = true;
    js['parent_id'] = widget.injectData.subBucketModel.id;
    js[Keys.id] = widget.injectData.subBucketModel.contentId;

    js['force_order'] = widget.injectData.subBucketModel.contentModel?.hasOrder?? true;
    js['media_ids'] = itemList.map((e) => e.id).toList();


    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        Navigator.of(context).pop(true);
      });
    };

    showLoading();
    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }
}
