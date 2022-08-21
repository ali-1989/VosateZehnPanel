
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:app/models/BucketModel.dart';
import 'package:app/models/enums.dart';
import 'package:app/models/subBuketModel.dart';

import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appManager.dart';
import 'package:app/tools/app/appSheet.dart';

class AddContainerPageInjectData {
  late final BucketModel bucketModel;
  SubBucketModel? subBucketModel;
}
///----------------------------------------------------------------
class AddContainerPage extends StatefulWidget {
  final AddContainerPageInjectData injectData;

  const AddContainerPage({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<AddContainerPage> createState() => _AddContainerPageState();
}
///============================================================================================
class _AddContainerPageState extends StateBase<AddContainerPage> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  Requester requester = Requester();
  late InputDecoration inputDecoration;
  PlatformFile? pickedImage;
  bool editMode = false;
  int? deletedImageId;
  String? coverUrl;

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


              SizedBox(height: 12),
              if(editMode)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                      onPressed: deleteItem,
                      child: Text('حذف آیتم')
                  ),
                ),

              SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue
                      ),
                      onPressed: onUploadCall,
                      child: Text('ثبت')
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
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

  void requestUpload(){
    final sb = widget.injectData.subBucketModel?? SubBucketModel();
    sb.title = titleCtr.text.trim();
    sb.description = descriptionCtr.text;
    sb.parentId = widget.injectData.bucketModel.id;
    sb.type = SubBucketTypes.list.id();
    sb.contentId = widget.injectData.subBucketModel?.contentId;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_sub_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.bucketModel.id;
    js[Keys.data] = sb.toMap();

    AppManager.addAppInfo(js);

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

    showLoading();
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
