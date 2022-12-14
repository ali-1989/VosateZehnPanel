import 'dart:async';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/structures/models/BucketModel.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/contentModel.dart';
import 'package:app/structures/models/speakerModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/pages/selectSpeakerPage.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appLoading.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/components/playerView.dart';

class AddMultiMediaPageInjectData {
  late BucketModel bucketModel;
  late SubBucketModel subBucketModel;
}
///----------------------------------------------------------------
class AddMultiMediaPage extends StatefulWidget {
  final AddMultiMediaPageInjectData injectData;

  const AddMultiMediaPage({required this.injectData, Key? key}) : super(key: key);

  @override
  State<AddMultiMediaPage> createState() => _AddMultiMediaPageState();
}
///============================================================================================
class _AddMultiMediaPageState extends StateBase<AddMultiMediaPage> {
  late Requester requester = Requester();
  ScrollController scrollCtr = ScrollController();
  List<MediaModel> mediaList = [];
  List<PlatformFile> newAddList = [];
  List<ListItemHolder> itemList = [];
  List<int> deletedList = [];
  SpeakerModel? speakerModel;
  int allCount = 0;
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
    //PagesEventBus.removeFor((SpeakersManagerPage).toString());

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text('????????????').bold(),

                      SizedBox(height: 5),
                      Builder(
                        builder: (ctx){
                          if(speakerModel == null){
                            return TextButton(
                                onPressed: gotoSelectSpeakerPage,
                                child: Text('????????????')
                            );
                          }

                          return GestureDetector(
                            onTap: onChangeSpeakerClick,
                            child: Column(
                              children: [
                                ClipOval(
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Builder(
                                      builder: (ctx){
                                        if(speakerModel!.profileModel != null){
                                          return Image.network(speakerModel!.profileModel!.url!, width: 85, fit: BoxFit.fill,);
                                        }

                                        return ColoredBox(color: Colors.blueGrey);
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),
                                Text(speakerModel!.name),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: onSaveClick,
                            child: Text('??????????')
                        ),
                      ),

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
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: pickMedia,
                          child: Text('???????? ???????? +')
                      ),

                      SizedBox(width: 40,),
                      Text('?????????? ????: $allCount').bold(),
                    ],
                  ),

                if(!assistCtr.hasState(state$fetchData))
                  Row(
                    children: [
                      Text('?????? ???????????? ???? ???????? '),
                      TextButton(
                        onPressed: tryClick,
                        child: Text('???????? ????????'),
                      ),
                    ],
                  )
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

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    itemBuilder: (ctx, idx){
                      return buildListItem(idx);
                    },
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
          play(itm);
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

                SizedBox(width: 10,),
                Expanded(
                    child: Text(itm.name, textDirection: TextDirection.ltr, textAlign: TextAlign.right,).englishFont(),
                ),

                IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    onPressed: (){
                      deleteItem(itm);
                    },
                    icon: Icon(AppIcons.delete, color: Colors.red,)
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void play(ListItemHolder item) async {
    if(item.isNew){
      return;
    }

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return Center(
              child: Card(
                  child: SizedBox(
                    width: 400,
                    height: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CloseButton(),

                        SizedBox(height: 80),
                        PlayerView(mediaUrl: (item.object as MediaModel).url),
                      ],
                    ),
                  )
              )
          );
        }
    );
  }

  void pickMedia() async {
    final p = await FilePicker.platform.pickFiles(
      allowedExtensions: ['mp3', 'mp4'],
      allowMultiple: false,
      withData: false,
      withReadStream: true,
      type: FileType.custom,
    );

    if(p != null) {
      newAddList.add(p.files.first);
      prepareItemList();

      assistCtr.updateMain();
    }
  }

  void prepareItemList(){
    itemList.clear();

    for(final k in newAddList){
      final t = ListItemHolder();
      t.id = Generator.generateDateMillWith6Digit();
      t.name = k.name;
      t.isNew = true;
      t.extension = PathHelper.getDotExtension(k.extension?? '');
      t.object = k;

      itemList.add(t);
    }

    for(final k in mediaList){
      final t = ListItemHolder();
      t.id = k.id!;
      t.name = k.fileName?? '-';
      t.extension = PathHelper.getDotExtension(k.url!);
      t.object = k;

      itemList.add(t);
    }

    allCount = itemList.length;
  }

  bool isVideo(ListItemHolder model){
    return PathHelper.getDotExtension(model.extension) == '.mp4';
  }

  void tryClick(){
    requestData();
    assistCtr.updateMain();
  }

  void onChangeSpeakerClick(){
    gotoSelectSpeakerPage();
  }

  void gotoSelectSpeakerPage() async {
    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return SelectSpeakerPage();
        }
    );

    if(result is SpeakerModel){
      speakerModel = result;
      assistCtr.updateMain();
    }
  }

  void onSaveClick(){
    if(speakerModel == null){
      AppSheet.showSheetOk(context, '???????????? ???? ???????????? ????????');
      return;
    }

    if(itemList.isEmpty){
      AppSheet.showSheetOk(context, '???? ?????? ???? ???????? ???????????? ????????');
      return;
    }

    requestSave();
  }

  void deleteItem(ListItemHolder itm) {
    AppSheet.showSheetYesNo(context, Text('?????? ???????? ?????? ????????'), () {
      if(itm.isNew){
        newAddList.removeWhere((element) => element == itm.object);
      }
      else {
        final m = (itm.object as MediaModel);
        deletedList.add(m.id!);
        mediaList.removeWhere((element) => element.id == m.id);

        widget.injectData.subBucketModel.contentModel!.mediaIds.removeWhere((element) => element == m.id);
      }

      prepareItemList();
      assistCtr.updateMain();
    }, () {});
  }

  void requestData(){
    mediaList.clear();

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

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final content = data['content'] as Map?;
      final speaker = data['speaker'] as Map?;
      final mList = data['media_list'] as List?;
      //allCount = data['all_count'];

      MediaManager.addItemsFromMap(mList);

      final contentModel = ContentModel.fromMap(content);

      widget.injectData.subBucketModel.contentId = contentModel.id;

      if(speaker != null && speaker.isNotEmpty) {
        speakerModel = SpeakerModel.fromMap(speaker);
        speakerModel?.profileModel = MediaManager.getById(speakerModel?.mediaId);
      }

      widget.injectData.subBucketModel.contentModel = contentModel;
      widget.injectData.subBucketModel.contentModel?.speakerModel = speakerModel;

      for(final k in contentModel.mediaIds){
        final mm = MediaManager.getById(k);

        if(mm != null) {
          mediaList.add(mm);
        }
      }

      prepareItemList();
      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context);
  }

  void requestSave(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_bucket_content';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['parent_id'] = widget.injectData.subBucketModel.id;
    js['speaker'] = speakerModel?.toMap();

    js[Keys.id] = widget.injectData.subBucketModel.contentId;

    if(widget.injectData.subBucketModel.contentModel != null) {
      js['current_media_ids'] = widget.injectData.subBucketModel.contentModel!.mediaIds;
    }

    PublicAccess.addAppInfo(js);

    final medias = <String, PlatformFile>{};
    final mediasInfo = <String, Map>{};

    for(final k in newAddList){
      medias['${Generator.generateDateMillWith6Digit()}'] = k;
    }

    for(final k in medias.entries){
      final map = {};
      map[Keys.fileName] = k.value.name;
      map['extension'] = PathHelper.getDotExtension(k.value.name);

      mediasInfo[k.key] = map;
    }

    js['medias_parts'] = medias.keys.toList();
    js['medias_info'] = mediasInfo;

    for(final k in medias.entries){
      final name = '${k.key}.${mediasInfo[k.key]!['extension']}';
      requester.httpItem.addBodyStream(k.key, name, k.value.readStream!, k.value.size);
    }

    if(deletedList.isNotEmpty){
      js['delete_media_ids'] = deletedList;
    }

    final progressStream = StreamController<double>();

    requester.httpItem.onSendProgress = (i, s){
      try {
        final p = MathHelper.percentInt(s, i);
        final dp = MathHelper.percentTop1(p);
        progressStream.sink.add(dp);
      }
      catch (e){
        debugPrint(e.toString());
      }
    };

    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));


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

    AppLoading.instance.showProgress(
      context,
      progressStream.stream,
      buttonText: '  ??????  ',
      message: '???? ?????? ??????????',
      buttonEvent: (){
        requester.httpRequestEvents = HttpRequestEvents();
        requester.dispose();
        AppLoading.instance.hideLoading(context);
      },
    );

    requester.bodyJson = null;
    requester.prepareUrl();
    requester.request(context);
  }
}
///===================================================================================
class ListItemHolder {
  late int id;
  late String name;
  late String extension;
  dynamic object;
  bool isNew = false;
}
