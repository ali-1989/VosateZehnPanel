import 'package:file_sizes/file_sizes.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mediaHelper.dart';
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
import 'package:vosate_zehn_panel/tools/app/appManager.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';

class AddMediaPageInjectData {
  late final BucketModel bucketModel;
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
  PlatformFile? pickedImage;
  PlatformFile? pickedMedia;
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
        maxWidth: 480,
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
                            if(pickedImage == null){
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
                      child: Text('انتخاب فایل')
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

              if(pickedMedia != null)
              Center(
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue
                      ),
                      onPressed: onUploadCall,
                      child: Text('آپلود')
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
    pickedImage = null;
    assistCtr.updateMain();
  }

  void pickImage() async {
    final p = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: false,
      type: FileType.custom,
    );

    if(p != null) {
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

  void requestUpload(){
    bool isVideo = PathHelper.getDotExtension(pickedMedia!.name) == '.mp4';

    final sb = SubBucketModel();
    sb.title = titleCtr.text.trim();
    sb.description = descriptionCtr.text;
    sb.parentId = widget.injectData.bucketModel.id;
    sb.type = isVideo ? 1 : 2;
    //sb.duration = ;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_sub_bucket';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.bucketModel.id;
    js[Keys.data] = sb.toMap();
    AppManager.addAppInfo(js);

    requester.httpItem.onSendProgress = (i, s){
      print('progres >>> $i   $s');
    };

    js['media'] = 'media';
    requester.httpItem.addBodyStream('media', '${Generator.generateDateMillWith6Digit()}.${isVideo? 'mp4': 'mp3'}', pickedMedia!.readStream!, pickedMedia!.size);

    if(pickedImage != null) {
      js['cover'] = 'cover';
      requester.httpItem.addBodyBytes('cover', '${Generator.generateDateMillWith6Digit()}.jpg', pickedImage!.bytes!);
    }
    else {
      if (editMode && deletedImageId != null) {
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

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      //PagesEventBus.getEventBus((ContentManagerPage).toString()).callEvent('update', null);

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        Navigator.of(context).pop(true);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }

}
