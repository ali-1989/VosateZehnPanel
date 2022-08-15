import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:vosate_zehn_panel/models/BucketModel.dart';
import 'package:vosate_zehn_panel/models/enums.dart';
import 'package:vosate_zehn_panel/pages/contentManagerPage.dart';
import 'package:vosate_zehn_panel/services/pagesEventBus.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appIcons.dart';
import 'package:vosate_zehn_panel/tools/app/appManager.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/tools/app/appThemes.dart';

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
  late Requester requester = Requester();
  late InputDecoration inputDecoration;
  PlatformFile? pickedImage;
  bool editMode = false;

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
      addPostOrCall(() => AppRoute.pop(context));
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
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: AppThemes.instance.currentTheme.successColor
                                  ),
                                    onPressed: onSaveBucket,
                                    child: Text('ذخیره')
                                ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void removeImage() async {
    if(editMode){
      AppSheet.showSheetYesNo(context, Text('آیا عکس حذف شود؟'), () {requestDeleteImage();}, () {});
      return;
    }

    pickedImage = null;

    assistCtr.updateMain();
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

    BucketModel bucketModel = BucketModel();
    bucketModel.bucketType = widget.injectData!.bucketType.id();
    bucketModel.title = title;
    bucketModel.description = descriptionCtr.text;

    if(editMode){
      bucketModel.id =  widget.injectData!.bucket!.id;
    }

    requestUpsertBucket(bucketModel);
  }

  void requestDeleteImage(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_bucket_image';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData!.bucket!.id;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      widget.injectData!.bucket!.imageModel = null;

      assistCtr.updateMain();
      PagesEventBus.getEventBus((ContentManagerPage).toString()).callEvent('update', null);
    };

    showLoading();
    requester.request(context);
  }

  void requestUpsertBucket(BucketModel bucketModel){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = widget.injectData!.bucketType.id();
    js[Keys.data] = bucketModel.toMapServer();
    AppManager.addAppInfo(js);

    if(pickedImage != null) {
      js['image'] = 'image';
      requester.httpItem.addBodyBytes('image', '${Generator.generateDateMillWith6Digit()}.jpg', pickedImage!.bytes!);
    }
    else {
      js['image'] = false;//todo in edit mode
    }

    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      editMode = true;
      AppSheet.showSheet$SuccessOperation(context);

      assistCtr.updateMain();
      PagesEventBus.getEventBus((ContentManagerPage).toString()).callEvent('update', null);
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }
}
