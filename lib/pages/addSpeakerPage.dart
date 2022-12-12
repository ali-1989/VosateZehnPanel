import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/speakerModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';

class AddSpeakerPageInjectData {
  SpeakerModel? speakerModel;
}
///----------------------------------------------------------------
class AddSpeakerPage extends StatefulWidget {
  final AddSpeakerPageInjectData injectData;

  const AddSpeakerPage({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<AddSpeakerPage> createState() => _AddSpeakerPageState();
}
///============================================================================================
class _AddSpeakerPageState extends StateBase<AddSpeakerPage> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  ScrollController scrollCtr = ScrollController();
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

    editMode = widget.injectData.speakerModel != null;

    if(editMode){
      titleCtr.text = widget.injectData.speakerModel!.name;
      descriptionCtr.text = widget.injectData.speakerModel!.description?? '';
      coverUrl = widget.injectData.speakerModel!.profileModel?.url;
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
                          Text('نام'),

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

              SizedBox(height: 10,),

              SizedBox(height: 20,),

              Center(
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue
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
    if(editMode && widget.injectData.speakerModel!.profileModel != null){
      AppSheet.showSheetYesNo(context, Text('آیا عکس حذف شود؟'), () {deleteImageInEditMode();}, () {});
      return;
    }

    pickedImage = null;
    assistCtr.updateMain();
  }

  void deleteImageInEditMode(){
    if(editMode){
      deletedImageId ??= widget.injectData.speakerModel!.profileModel!.id;

      coverUrl = null;
      widget.injectData.speakerModel!.mediaId = null;
      widget.injectData.speakerModel!.profileModel = null;
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
      AppSheet.showSheetOk(context, 'لطفا نام را وارد کنید');
      return;
    }

    requestUpload();
  }

  void requestUpload(){

    final sb = widget.injectData.speakerModel?? SpeakerModel();
    sb.name = titleCtr.text.trim();
    sb.description = descriptionCtr.text;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'upsert_speaker';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.speakerModel?.id;
    js[Keys.data] = sb.toMap();

    PublicAccess.addAppInfo(js);

    if(pickedImage != null) {
      js['image'] = 'image';
      requester.httpItem.addBodyBytes('image', '${Generator.generateDateMillWith6Digit()}.jpg', pickedImage!.bytes!);
    }
    else {
      if (deletedImageId != null) {
        js['image'] = false;
      }
    }

    if(deletedImageId != null){
      js['delete_cover_id'] = deletedImageId;
    }

    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
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

}
