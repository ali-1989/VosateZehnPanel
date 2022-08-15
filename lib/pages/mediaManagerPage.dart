import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:vosate_zehn_panel/models/BucketModel.dart';
import 'package:vosate_zehn_panel/models/enums.dart';
import 'package:vosate_zehn_panel/models/subBuketModel.dart';
import 'package:vosate_zehn_panel/pages/addMediaPage.dart';
import 'package:vosate_zehn_panel/pages/contentManagerPage.dart';
import 'package:vosate_zehn_panel/services/pagesEventBus.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appIcons.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/tools/app/appThemes.dart';

class MediaManagerPageInjectData {
  late BucketTypes bucketType;
  BucketModel? bucket;
}
///----------------------------------------------------------------
class MediaManagerPage extends StatefulWidget {
  static final route = GoRoute(
    path: 'MediaManager',
    name: (MediaManagerPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => MediaManagerPage(injectData: state.extra as MediaManagerPageInjectData?),
  );

  final MediaManagerPageInjectData? injectData;

  const MediaManagerPage({
    Key? key,
    this.injectData,
  }) : super(key: key);

  @override
  State<MediaManagerPage> createState() => _MediaManagerPageState();
}
///============================================================================================
class _MediaManagerPageState extends StateBase<MediaManagerPage> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  late Requester requester = Requester();
  late InputDecoration inputDecoration;
  late BucketModel bucketModel;
  PlatformFile? pickedImage;
  List<SubBucketModel> mediaList = [];
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
      bucketModel = widget.injectData!.bucket?? BucketModel();

      if(editMode){
        titleCtr.text = bucketModel.title;
        descriptionCtr.text = bucketModel.description?? '';
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
            title: Text(widget.injectData?.bucket == null? 'ایجاد محتوا' : 'مدیریت محتوا'),
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
        child: ColoredBox(
          color: Colors.white,
          child: MaxWidth(
            maxWidth: 500,
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

                  Visibility(
                    visible: editMode,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('محتوا'),

                            ElevatedButton(
                                onPressed: onAddMedia,
                                child: Text('اضافه کردن')
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: mediaList.length,
                                itemBuilder: (ctx, idx){
                                  return buildListItem(idx);
                                }
                            )
                        ).wrapBoxBorder(),
                      ],
                    ),
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
    //final itm = mediaList[idx];

    return ColoredBox(color: ColorHelper.getRandomRGB(),
        child: SizedBox(height: 20,));
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

    bucketModel = BucketModel();
    bucketModel.bucketType = widget.injectData!.bucketType.id();
    bucketModel.title = title;
    bucketModel.description = descriptionCtr.text;

    if(editMode){
      bucketModel.id =  widget.injectData!.bucket!.id;
    }

    requestUpsertBucket();
  }

  void onAddMedia() async {
    final inject = AddMediaPageInjectData();
    inject.level2model = SubBucketModel();

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddMediaPage(injectData: inject);
        }
    );

    if(inject.level2model.contentList.isNotEmpty){
      bucketModel.level2List.add(inject.level2model);

      assistCtr.updateMain();
    }
  }

  void requestDeleteImage(){
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

  void requestUpsertBucket(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = widget.injectData!.bucketType.bucketName();
    js[Keys.data] = bucketModel.toMapServer();

    if(pickedImage != null) {
      js['image'] = 'image';
      requester.httpItem.addBodyBytes('image', 'image', pickedImage!.bytes!);
    }
    else {
      js['image'] = false;//todo in edit mode
    }

    requester.prepareUrl();
    requester.bodyJson = js;

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
    requester.request(context);
  }
}
