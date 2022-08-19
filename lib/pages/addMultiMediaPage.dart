import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';

import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:vosate_zehn_panel/managers/mediaManager.dart';
import 'package:vosate_zehn_panel/models/BucketModel.dart';
import 'package:vosate_zehn_panel/models/speakerModel.dart';
import 'package:vosate_zehn_panel/models/subBuketModel.dart';
import 'package:vosate_zehn_panel/pages/addSpeakerPage.dart';
import 'package:vosate_zehn_panel/pages/selectSpeakerPage.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appIcons.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/views/emptyData.dart';
import 'package:vosate_zehn_panel/views/notFetchData.dart';


class AddMultiMediaPageInjectData {
  late BucketModel bucketModel;
  SubBucketModel? subBucketModel;
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
  List<MediaModel> mediaList = [];
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

  Widget buildBody(){
    return Scrollbar(
      trackVisibility: true,
      thumbVisibility: true,
      child: SingleChildScrollView(
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
                      Text('گوینده').bold(),

                      SizedBox(height: 5),
                      Builder(
                        builder: (ctx){
                          if(speakerModel == null){
                            return TextButton(
                                onPressed: gotoSelectSpeakerPage,
                                child: Text('انتخاب')
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
                            style: ElevatedButton.styleFrom(primary: Colors.blue),
                            onPressed: (){},
                            child: Text('ذخیره')
                        ),
                      ),

                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                            //style: ElevatedButton.styleFrom(primary: Colors.blue),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('برگشت')
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
                          onPressed: gotoAddPage,
                          child: Text('مدیا جدید +')
                      ),

                      SizedBox(width: 40,),
                      Text('تعداد کل: $allCount').bold(),
                    ],
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

                  if(!assistCtr.hasState(state$fetchData)){
                    return SizedBox(
                      height: 200,
                        child: Center(child: NotFetchData(tryClick: tryClick,))
                    );
                  }

                  if(mediaList.isEmpty){
                    return SizedBox(
                      height: 200,
                        child: Center(child: EmptyData())
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: mediaList.length,
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

  /*
  * /*if(itm.profileModel != null){
                        return Image.network(itm.profileModel!.url!, width: 85, fit: BoxFit.fill,);
                      }*/

                      return Image.asset(AppImages.appIcon, width: 85, fit: BoxFit.fill);*/

  Widget buildListItem(int idx){
    final itm = mediaList[idx];

    return SizedBox(
      key: ValueKey(itm.id!),
      height: 80,
      child: InkWell(
        onTap: (){
          //play(itm);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isVideo(itm)? AppIcons.videoCamera: AppIcons.headset
                ),

                SizedBox(width: 12,),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    onPressed: (){
                      //todo deleteItem(itm);
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

  bool isVideo(MediaModel model){
    return PathHelper.getDotExtension(model.url?? '') == '.mp4';
  }

  void gotoAddPage() async {
    final inject = AddSpeakerPageInjectData();

    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddSpeakerPage(injectData: inject);
        }
    );

    if(result != null && result){
      isInLoadData = true;
      requestData();
    }
  }

  void gotoEditePage(SpeakerModel speakerModel) async {
    final inject = AddSpeakerPageInjectData();
    inject.speakerModel = speakerModel;

    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddSpeakerPage(injectData: inject);
        }
    );

    if(result != null && result){
      isInLoadData = true;
      requestData();
    }
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

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void deleteItem(SpeakerModel itm) {
    AppSheet.showSheetYesNo(context, Text('آیا گوینده حذف شود؟'), () {
      requestDeleteSpeaker(itm.id!);
    }, () {});
  }

  void requestDeleteSpeaker(int id){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_speaker';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = id;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      mediaList.removeWhere((element) => element.id == id);
      allCount--;
      
      assistCtr.updateMain();
    };

    showLoading();
    requester.request(context);
  }

  void requestData(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_content_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final dList = data['speaker_list'];
      final mList = data['media_list'];
      allCount = data['all_count'];

      MediaManager.addItemsFromMap(mList);

      for(final k in dList){
        final b = MediaModel.fromMap(k);

        mediaList.add(b);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context);
  }
}
