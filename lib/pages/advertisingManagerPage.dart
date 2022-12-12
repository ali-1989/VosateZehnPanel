import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/advertisingModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/states/errorOccur.dart';

class AdvertisingManagerPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'AdvertisingManager',
      name: (AdvertisingManagerPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => const AdvertisingManagerPage(),
  );

  const AdvertisingManagerPage({Key? key}) : super(key: key);

  @override
  State<AdvertisingManagerPage> createState() => _AdvertisingManagerPageState();
}
///============================================================================================
class _AdvertisingManagerPageState extends StateBase<AdvertisingManagerPage> {
  Requester requester = Requester();
  bool isInLoadData = true;
  String state$fetchData = 'state_fetchData';
  TextEditingController url1Ctr = TextEditingController();
  TextEditingController url2Ctr = TextEditingController();
  TextEditingController url3Ctr = TextEditingController();
  AdvertisingModel ad1 = AdvertisingModel()..tag = 'avd1';
  AdvertisingModel ad2 = AdvertisingModel()..tag = 'avd2';
  AdvertisingModel ad3 = AdvertisingModel()..tag = 'avd3';
  late InputDecoration inputDecoration;

  @override
  void initState(){
    super.initState();

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      isDense: true,
      hintText: 'url'
    );

    requestAdvertising();
  }

  @override
  void dispose() {
    requester.dispose();
    url1Ctr.dispose();
    url2Ctr.dispose();
    url3Ctr.dispose();

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
            title: Text('مدیریت تبلیغات'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
  }

  Widget buildBody(){
    return MaxWidth(
      maxWidth: 500,
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox.expand(
          child: Builder(
            builder: (ctx){
              if(isInLoadData){
                return Center(
                  child: SizedBox(
                    width: 60,
                      height: 60,
                      child: CircularProgressIndicator()
                  ),
                );
              }

              if(!assistCtr.hasState(state$fetchData)){
                return ErrorOccur(tryClick: tryClick,);
              }

              return buildBodyList();
            },
          ),
        ),
      ),
    );
  }

  Widget buildBodyList(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تبلیغ اول:').bold().boldFont().fsR(4),
            SizedBox(height: 10),

            Builder(
                builder: (context) {
                  if(ad1.platformFile == null && ad1.mediaModel == null){
                    return SizedBox(
                      width: 90,
                      height: 90,
                      child: Center(
                          child: IconButton(
                              onPressed: (){
                                pickImage(ad1);
                              },
                              icon: Icon(AppIcons.add)
                          )
                      ),
                    ).wrapDotBorder();
                  }

                  return Stack(
                    children: [
                      Builder(
                        builder: (ctx){
                          if(ad1.mediaModel?.url != null){
                            return Image.network(ad1.mediaModel!.url!,
                              width: 150, height: 150, fit: BoxFit.fill
                            );
                          }

                          if(ad1.platformFile != null){
                            return Image.memory(ad1.platformFile!.bytes!,
                              width: 150, height: 150, fit: BoxFit.cover
                            );
                          }

                          return SizedBox();
                        },
                      ),

                      Icon(
                        AppIcons.delete,
                        color: Colors.white,
                      )
                          .wrapMaterial(
                        materialColor: Colors.black.withAlpha(100),
                        onTapDelay: (){
                          removeImage(ad1);
                        },
                      )
                    ],
                  );
                }
            ),

            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                    onPressed: saveUrl1,
                    child: Text('ذخیره')
                ),

                SizedBox(width: 10,),

                Expanded(
                  child: TextField(
                    controller: url1Ctr,
                    decoration: inputDecoration,
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),
            Text('تبلیغ دوم:').bold().boldFont().fsR(4),
            SizedBox(height: 10),

            Builder(
                builder: (context) {
                  if(ad2.platformFile == null && ad2.mediaModel == null){
                    return SizedBox(
                      width: 90,
                      height: 90,
                      child: Center(
                          child: IconButton(
                              onPressed: (){
                                pickImage(ad2);
                              },
                              icon: Icon(AppIcons.add)
                          )
                      ),
                    ).wrapDotBorder();
                  }

                  return Stack(
                    children: [
                      if(ad2.mediaModel?.url != null)
                        Image.network(ad2.mediaModel!.url!,
                          width: 150, height: 150, fit: BoxFit.cover,),

                      if(ad2.platformFile != null)
                        Image.memory(ad2.platformFile!.bytes!,
                          width: 150, height: 150, fit: BoxFit.cover,),

                      Icon(
                        AppIcons.delete,
                        color: Colors.white,
                      )
                          .wrapMaterial(
                        materialColor: Colors.black.withAlpha(100),
                        onTapDelay: (){
                          removeImage(ad2);
                        },
                      )
                    ],
                  );
                }
            ),

            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                    onPressed: saveUrl2,
                    child: Text('ذخیره')
                ),

                SizedBox(width: 10,),

                Expanded(
                  child: TextField(
                    controller: url2Ctr,
                    decoration: inputDecoration,
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),
            Text('تبلیغ سوم:').bold().boldFont().fsR(4),
            SizedBox(height: 10),

            Builder(
                builder: (context) {
                  if(ad3.platformFile == null && ad3.mediaModel == null){
                    return SizedBox(
                      width: 90,
                      height: 90,
                      child: Center(
                          child: IconButton(
                              onPressed: (){
                                pickImage(ad3);
                              },
                              icon: Icon(AppIcons.add)
                          )
                      ),
                    ).wrapDotBorder();
                  }

                  return Stack(
                    children: [
                      if(ad3.mediaModel?.url != null)
                        Image.network(ad3.mediaModel!.url!,
                          width: 150, height: 150, fit: BoxFit.cover,),

                      if(ad3.platformFile != null)
                        Image.memory(ad3.platformFile!.bytes!,
                          width: 150, height: 150, fit: BoxFit.cover,),

                      Icon(
                        AppIcons.delete,
                        color: Colors.white,
                      )
                          .wrapMaterial(
                        materialColor: Colors.black.withAlpha(100),
                        onTapDelay: (){
                          removeImage(ad3);
                        },
                      )
                    ],
                  );
                }
            ),

            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                    onPressed: saveUrl3,
                    child: Text('ذخیره')
                ),

                SizedBox(width: 10,),

                Expanded(
                  child: TextField(
                    controller: url3Ctr,
                    decoration: inputDecoration,
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void tryClick(){
    requestAdvertising();
    assistCtr.updateMain();
  }

  void pickImage(AdvertisingModel advertisingModel) async {
    final p = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: false,
      type: FileType.custom,
    );

    if(p != null) {
      advertisingModel.platformFile = p.files.first;
      requestSetAdvertising(advertisingModel);
    }
  }

  void removeImage(AdvertisingModel advertisingModel) async {
    advertisingModel.platformFile = null;

    if(advertisingModel.mediaModel != null){
      requestDeleteAdvertising(advertisingModel);
    }
    else {
      assistCtr.updateMain();
    }
  }

  void saveUrl1() async {
    requestSaveUrl(url1Ctr.text.trim(), ad1);
  }

  void saveUrl2() async {
    requestSaveUrl(url2Ctr.text.trim(), ad2);
  }

  void saveUrl3() async {
    requestSaveUrl(url3Ctr.text.trim(), ad3);
  }

  void requestAdvertising(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_advertising_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInLoadData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInLoadData = false;

      final adv = data['advertising_list'];
      final mList = data['media_list'] as List?;

      MediaManager.addItemsFromMap(mList);

      for(final k in adv){
        final tag = k['tag'];

        if(tag == 'avd1'){
          ad1 = AdvertisingModel.fromMap(k);
          ad1.mediaModel = MediaManager.getById(ad1.mediaId!);
          url1Ctr.text = ad1.url?? '';
        }

        if(tag == 'avd2'){
          ad2 = AdvertisingModel.fromMap(k);
          ad2.mediaModel = MediaManager.getById(ad2.mediaId!);
          url2Ctr.text = ad2.url?? '';
        }

        if(tag == 'avd3'){
          ad3 = AdvertisingModel.fromMap(k);
          ad3.mediaModel = MediaManager.getById(ad3.mediaId!);
          url3Ctr.text = ad3.url?? '';
        }
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.prepareUrl();
    requester.request(context);
  }

  void requestSaveUrl(String url, AdvertisingModel model){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_advertising_url';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['tag'] = model.tag;
    js['url'] = url.isEmpty? null : url;

    requester.httpRequestEvents.onFailState = (req, r) async {
      hideLoading();
      AppSheet.showSheet$OperationFailedTryAgain(context);
    };

    requester.httpRequestEvents.onStatusError = (req, data, code, tCode) async {
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      hideLoading();
      AppSheet.showSheet$SuccessOperation(context);
    };

    showLoading();
    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }

  void requestDeleteAdvertising(AdvertisingModel model){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_advertising_image';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['tag'] = model.tag;

    requester.httpRequestEvents.onFailState = (req, r) async {
      hideLoading();
      AppSheet.showSheet$OperationFailedTryAgain(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      hideLoading();
      model.mediaModel = null;

      assistCtr.updateMain();
      AppSheet.showSheet$SuccessOperation(context);
    };

    showLoading();
    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }

  void requestSetAdvertising(AdvertisingModel model){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_advertising';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['tag'] = model.tag;
    js['media'] = 'media';

    PublicAccess.addAppInfo(js);
    requester.bodyJson = null;
    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));

    final name = Generator.generateDateMillWithKey(8) + PathHelper.getDotExtension(model.platformFile!.name);
    requester.httpItem.addBodyBytes('media', name, model.platformFile!.bytes!);

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      model.platformFile = null;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context);
      assistCtr.updateMain();
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }
}
