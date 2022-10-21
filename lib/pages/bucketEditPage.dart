import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';

import 'package:app/models/BucketModel.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/contentManagerPage.dart';
import 'package:app/services/pagesEventBus.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appThemes.dart';

class BuketEditPageInjectData {
  late BucketTypes bucketType;
  BucketModel? bucket;
}
///----------------------------------------------------------------
class BuketEditPage extends StatefulWidget {
  static final route = GoRoute(
    path: 'BuketEditPage',
    name: (BuketEditPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => BuketEditPage(injectData: state.extra as BuketEditPageInjectData?),
  );

  final BuketEditPageInjectData? injectData;

  const BuketEditPage({
    Key? key,
    this.injectData,
  }) : super(key: key);

  @override
  State<BuketEditPage> createState() => _BuketEditPageState();
}
///============================================================================================
class _BuketEditPageState extends StateBase<BuketEditPage> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  ScrollController scrollCtr = ScrollController();
  Requester requester = Requester();
  late InputDecoration inputDecoration;
  PlatformFile? pickedImage;
  bool editMode = false;
  int? deletedImageId;

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

    if(widget.injectData == null) {
      addPostOrCall(() => AppRoute.popPage(context));
    }
    else {
      editMode = widget.injectData!.bucket != null;

      if(editMode){
        titleCtr.text = widget.injectData!.bucket!.title;
        descriptionCtr.text = widget.injectData!.bucket!.description?? '';
      }
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
    if(widget.injectData == null){
      return SizedBox();
    }

    return Assist(
      controller: assistCtr,
      builder: (context, controller, sendData) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text(editMode? 'ویرایش محتوا': 'ایجاد محتوا'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  Widget buildBody(){
    BucketModel bucketModel = widget.injectData!.bucket?? BucketModel();

    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      controller: scrollCtr,
      child: SingleChildScrollView(
        controller: scrollCtr,
        child: MaxWidth(
          maxWidth: 500,
          child: ColoredBox(
            color: Colors.white,
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
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppThemes.instance.currentTheme.successColor
                                      ),
                                        onPressed: onSaveBucket,
                                        child: Text('ذخیره')
                                    ),
                                  ),

                                  SizedBox(width: 20,),
                                  SizedBox(
                                    width: 110,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppThemes.instance.currentTheme.errorColor
                                        ),
                                        onPressed: deleteBucketCall,
                                        child: Text('حذف آیتم')
                                    ),
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
                          //SizedBox(height: 10),
                          Text('عکس'),

                          SizedBox(height: 10),

                          Builder(
                              builder: (context) {
                                if(pickedImage == null && bucketModel.imageModel == null){
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
                                    Builder(
                                      builder: (ctx){
                                        if(pickedImage != null){
                                          return Image.memory(pickedImage!.bytes!,
                                            width: 100, height: 100, fit: BoxFit.cover,
                                          );
                                        }

                                        return Image.network(bucketModel.imageModel!.url!,
                                          width: 100, height: 100, fit: BoxFit.cover
                                        );
                                      },
                                    ),

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

                  SizedBox(height: 10,),
                  Builder(
                    builder: (ctx){
                      if(editMode){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CheckBoxRow(
                                value: bucketModel.isHide,
                                description: Text('حالت مخفی'),
                                onChanged: (v){
                                  bucketModel.isHide = !bucketModel.isHide;
                                  assistCtr.updateMain();
                                }
                            ),
                          ],
                        );
                      }

                      return SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void deleteBucketCall() async {
    AppSheet.showSheetYesNo(context, Text('آیا از حذف اطمینان دارید؟'), () {requestDeleteBucket();}, () {});
  }

  void removeImage() async {
    if(editMode){
      AppSheet.showSheetYesNo(context, Text('آیا عکس حذف شود؟'), () {deleteImageInEditMode();}, () {});
      return;
    }

    pickedImage = null;
    assistCtr.updateMain();
  }

  void deleteImageInEditMode(){
    if(editMode){
      deletedImageId ??= widget.injectData!.bucket!.imageModel!.id;

      widget.injectData!.bucket!.mediaId = null;
      widget.injectData!.bucket!.imageModel = null;
      assistCtr.updateMain();
    }
  }

  void pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: false,
      type: FileType.custom,
    );

    if(result != null) {
      pickedImage = result.files.first;
      assistCtr.updateMain();
    }
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void onSaveBucket(){
    final title = titleCtr.text.trim();

    if(title.isEmpty){
      AppSheet.showSheetOk(context, 'عنوان را بنویسید');
      return;
    }

    BucketModel bucketModel;

    if(editMode){
      bucketModel = widget.injectData!.bucket!;
    }
    else {
      bucketModel = BucketModel();
      bucketModel.bucketType = widget.injectData!.bucketType.id();
    }

    bucketModel.title = title;
    bucketModel.description = descriptionCtr.text;

    requestUpsertBucket(bucketModel);
  }

  void requestUpsertBucket(BucketModel bucketModel){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = widget.injectData!.bucketType.id();
    js[Keys.data] = bucketModel.toMapServer();
    PublicAccess.addAppInfo(js);

    if(pickedImage != null) {
      js['image'] = 'image';
      requester.httpItem.addBodyBytes('image', '${Generator.generateDateMillWith6Digit()}.jpg', pickedImage!.bytes!);
    }
    else {
      if (editMode && deletedImageId != null) {
        js['image'] = false;
      }
    }

    if(deletedImageId != null){
      js['delete_media_id'] = deletedImageId;
    }

    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      PagesEventBus.getEventBus((ContentManagerPage).toString()).callEvent('update', null);

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        AppRoute.popPage(context);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }

  void requestDeleteBucket(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData!.bucket!.id;

    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      PagesEventBus.getEventBus((ContentManagerPage).toString()).callEvent('update', null);

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        AppRoute.popPage(context);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }
}
