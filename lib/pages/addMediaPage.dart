import 'dart:async';

import 'package:file_sizes/file_sizes.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:vosate_zehn_panel/models/BucketModel.dart';
import 'package:vosate_zehn_panel/models/subBuketModel.dart';

import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appIcons.dart';
import 'package:vosate_zehn_panel/tools/app/appLoading.dart';
import 'package:vosate_zehn_panel/tools/app/appManager.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:webviewx/webviewx.dart';

class AddMediaPageInjectData {
  late final BucketModel bucketModel;
  SubBucketModel? subBucketModel;
}
///----------------------------------------------------------------
class AddMediaPage extends StatefulWidget {
  final AddMediaPageInjectData injectData;

  const AddMediaPage({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<AddMediaPage> createState() => _AddMediaPageState();
}
///============================================================================================
class _AddMediaPageState extends StateBase<AddMediaPage> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  Requester requester = Requester();
  late InputDecoration inputDecoration;
  WebViewXController? webviewController;
  bool isInLoadWebView = true;
  PlatformFile? pickedImage;
  PlatformFile? pickedMedia;
  bool editMode = false;
  int? deletedImageId;
  int? deletedMediaId;
  String? coverUrl;
  String? mediaUrl;

  @override
  void initState(){
    super.initState();

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.all(12),
    );

    editMode = widget.injectData.subBucketModel != null;

    if(editMode){
      titleCtr.text = widget.injectData.subBucketModel!.title;
      descriptionCtr.text = widget.injectData.subBucketModel!.description?? '';
      coverUrl = widget.injectData.subBucketModel!.imageModel?.url;
      mediaUrl = widget.injectData.subBucketModel!.mediaModel?.url;
    }
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
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: onBackPress,
                                  child: Text('برگشت')
                              )
                            ],
                          ),

                          SizedBox(height: 15,),
                          Text('عنوان'),

                          TextField(
                            controller: titleCtr,
                            decoration: inputDecoration,
                          ),
                        ],
                      ),
                    ),
                  ),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('عکس'),

                      SizedBox(height: 10),

                      Builder(
                          builder: (context) {
                            if(pickedImage == null && coverUrl == null){
                              return SizedBox(
                                width: 90,
                                height: 90,
                                child: Center(
                                    child: IconButton(
                                        onPressed: pickImage,
                                        icon: Icon(AppIcons.add)
                                    )
                                ),
                              ).wrapDotBorder();
                            }

                            return Stack(
                              children: [
                                if(coverUrl != null)
                                  Image.network(coverUrl!,
                                    width: 100, height: 100, fit: BoxFit.cover,),

                                if(coverUrl == null)
                                Image.memory(pickedImage!.bytes!,
                                  width: 100, height: 100, fit: BoxFit.cover,),

                                Icon(
                                  AppIcons.delete,
                                  color: Colors.white,
                                )
                                    .wrapMaterial(
                                  materialColor: Colors.black.withAlpha(100),
                                  onTapDelay: removeImage,
                                )
                              ],
                            );
                          }
                      ),
                    ],
                  )
                ],
              ),

              SizedBox(height: 10,),
              Text('توضیحات'),

              TextField(
                controller: descriptionCtr,
                minLines: 2,
                maxLines: 4,
                decoration: inputDecoration,
              ),

              SizedBox(height: 20,),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: pickMedia,
                      child: Text(editMode? 'تغییر فایل' : 'انتخاب فایل')
                  ),

                  SizedBox(width: 30,),
                  if(pickedMedia != null)
                    Flexible(
                      child: Chip(
                          label: Text(
                              '${pickedMedia!.name}  |  ${FileSize.getSize(pickedMedia!.size, precision: PrecisionValue.None)}',
                            maxLines: 1,
                          )
                      ),
                    ),
                ],
              ),

              SizedBox(height: 10,),

              if(mediaUrl != null)
                Center(
                  child: WebViewX(
                    width: 200,
                    height: isVideo()? 200: 100,
                    onWebViewCreated: (ctr) {
                      if(webviewController == null) {
                        webviewController = ctr;
                        if(isVideo()) {
                          ctr.loadContent('html/vplayer.html', SourceType.html, fromAssets: true);
                        }
                        else {
                          ctr.loadContent('html/aplayer.html', SourceType.html, fromAssets: true);
                        }
                      }
                    },
                    onPageFinished: (t){
                      isInLoadWebView = false;
                      setMediaToPlayer();
                      assistCtr.updateMain();
                    },
                  ),
                ),

              SizedBox(height: 20,),
              if(editMode || pickedMedia != null)
              Center(
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue
                      ),
                      onPressed: onUploadCall,
                      child: Text(editMode? 'ثبت': 'آپلود')
                  ),
                ),
              ),

              SizedBox(height: 12),
              if(editMode)
                Center(
                  child: SizedBox(
                    width: 110,
                    child: ElevatedButton(
                        onPressed: deleteItem,
                        child: Text('حذف آیتم')
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  void setMediaToPlayer() async {
    final cmd = '''
      document.getElementById("v_player").src = '$mediaUrl';
    ''';

    await webviewController?.evalRawJavascript(cmd);
  }

  void removeImage() async {
    if(editMode && widget.injectData.subBucketModel!.imageModel != null){
      AppSheet.showSheetYesNo(context, Text('آیا عکس حذف شود؟'), () {deleteImageInEditMode();}, () {});
      return;
    }

    pickedImage = null;
    assistCtr.updateMain();
  }

  void deleteImageInEditMode(){
    if(editMode){
      deletedImageId ??= widget.injectData.subBucketModel!.imageModel!.id;

      coverUrl = null;
      widget.injectData.subBucketModel!.coverId = null;
      widget.injectData.subBucketModel!.imageModel = null;
      assistCtr.updateMain();
    }
  }

  void pickImage() async {
    final p = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: false,
      type: FileType.custom,
    );

    if(p != null) {
      coverUrl = null;
      pickedImage = p.files.first;
      assistCtr.updateMain();
    }
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
      if(editMode){
        deletedMediaId ??= widget.injectData.subBucketModel!.mediaId;

        mediaUrl = null;
        widget.injectData.subBucketModel!.mediaId = null;
        widget.injectData.subBucketModel!.mediaModel = null;
        assistCtr.updateMain();
      }

      pickedMedia = p.files.first;
      assistCtr.updateMain();
    }
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void onBackPress(){
    Navigator.of(context).pop();
  }

  void onUploadCall(){
    final title = titleCtr.text.trim();

    if(title.isEmpty){
      AppSheet.showSheetOk(context, 'لطفا عنوان را وارد کنید');
      return;
    }

    requestUpload();
  }

  bool isVideo(){
    if(pickedMedia != null) {
      return PathHelper.getDotExtension(pickedMedia!.name) == '.mp4';
    }
    else {
      return PathHelper.getDotExtension(widget.injectData.subBucketModel?.mediaModel?.url?? '') == '.mp4';
    }
  }

  void requestUpload(){

    final sb = widget.injectData.subBucketModel?? SubBucketModel();
    sb.title = titleCtr.text.trim();
    sb.description = descriptionCtr.text;
    sb.parentId = widget.injectData.bucketModel.id;
    sb.type = isVideo() ? 1 : 2;
    //sb.duration = ;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_sub_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.bucketModel.id;
    js[Keys.data] = sb.toMap();
    js[Keys.fileName] = pickedMedia?.name?? widget.injectData.subBucketModel?.mediaModel?.fileName;
    AppManager.addAppInfo(js);

    final extension = isVideo()? 'mp4': 'mp3';
    final progressStream = StreamController<double>();

    requester.httpItem.onSendProgress = (i, s){
      final p = i / s * 100;
      final dp = MathHelper.percentTop1(p);
      progressStream.sink.add(dp);
    };

    if(pickedMedia != null) {
      js['media'] = 'media';
      requester.httpItem.addBodyStream('media', '${Generator.generateDateMillWith6Digit()}.$extension', pickedMedia!.readStream!, pickedMedia!.size);
    }

    if(pickedImage != null) {
      js['cover'] = 'cover';
      requester.httpItem.addBodyBytes('cover', '${Generator.generateDateMillWith6Digit()}.jpg', pickedImage!.bytes!);
    }
    else {
      if (deletedImageId != null) {
        js['cover'] = false;
      }
    }

    if(deletedImageId != null){
      js['delete_cover_id'] = deletedImageId;
    }

    if(deletedMediaId != null){
      js['delete_media_id'] = deletedMediaId;
    }

    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusError = (req, data, code, sCode) async {
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        Navigator.of(context).pop(true);
      });
    };

    AppLoading.instance.showProgress(
        context,
        progressStream.stream,
      buttonText: '  لغو  ',
      message: 'در حال آپلود',
      buttonEvent: (){
        requester.httpRequestEvents = HttpRequestEvents();
        requester.dispose();
        AppLoading.instance.hideLoading(context);
      },
    );

    requester.prepareUrl();
    requester.request(context);
  }

  void deleteItem() {
    AppSheet.showSheetYesNo(context, Text('آیا از حذف اطمینان دارید؟'), () {requestDeleteSubBucket();}, () {});
  }

  void requestDeleteSubBucket(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_sub_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.subBucketModel?.id;

    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        Navigator.of(context).pop(true);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }
}
