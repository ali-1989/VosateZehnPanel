import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';

import 'package:vosate_zehn_panel/models/contentModel.dart';
import 'package:vosate_zehn_panel/models/subBuketModel.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appDialogIris.dart';
import 'package:vosate_zehn_panel/tools/app/appIcons.dart';
import 'package:vosate_zehn_panel/tools/app/appToast.dart';

class AddMediaPageInjectData {
  late final SubBucketModel level2model;
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
  late InputDecoration inputDecoration;
  FilePickerResult? imagePickerResult;
  bool multiMedia = false;

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
    titleCtr.dispose();
    descriptionCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                                onPressed: onBackPress,
                                child: Text('برگشت')
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
                      Text('عکس'),

                      SizedBox(height: 10),

                      Builder(
                          builder: (context) {
                            if(imagePickerResult == null){
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
                                Image.memory(imagePickerResult!.files.first.bytes!,
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

              SizedBox(height: 10,),
              CheckBoxRow(
                  value: multiMedia,
                  description: Text('چند محتوایی'),
                  onChanged: (v){
                    multiMedia = !multiMedia;
                    assistCtr.updateMain();
                  }
              ),

              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('محتوا'),

                  ElevatedButton(
                      onPressed: pickMedia,
                      child: Text('اضافه کردن')
                  ),
                ],
              ),

              SizedBox(height: 10,),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 0,//mediaList.length,
                      itemBuilder: (ctx, idx){
                        return buildListItem(idx);
                      }
                  )
              ).wrapBoxBorder(),
            ],
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
    imagePickerResult = null;
    assistCtr.updateMain();
  }

  void pickImage() async {
    imagePickerResult = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: false,
      type: FileType.custom,
    );

    assistCtr.updateMain();
  }

  void pickMedia() async {
    final mediaPickerResult = await FilePicker.platform.pickFiles(
      allowedExtensions: ['mp3', 'mp4'],
      allowMultiple: multiMedia,
      type: FileType.custom,
    );

    if(mediaPickerResult != null){
      if(!multiMedia){
        widget.injectData.level2model.pickedFile = mediaPickerResult.files.first;
      }
      else {
        for (final k in mediaPickerResult.files) {
          bool exist = false;

          for (final k2 in widget.injectData.level2model.pickedFiles){
            if(k.name == k2.name && k.size == k2.size){
              exist = true;
              AppToast.showToast(context, 'موارد تکراری اضافه نمی شود');
              break;
            }
          }

          if(!exist){
            widget.injectData.level2model.pickedFiles.add(k);
          }
        }
      }

      assistCtr.updateMain();
    }
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void onBackPress(){
    if(widget.injectData.level2model.contentList.isEmpty){
      AppDialogIris.instance.showYesNoDialog(
          context,
          desc: 'لیست رسانه ها خالی می باشد. در صورت خروج محتوا حذف می شود',
          yesText: 'خروج',
          noText: 'اصلاح',
          yesFn: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          noFn: (){}
      );

      return;
    }

    final title = titleCtr.text.trim();

    if(title.isEmpty && widget.injectData.level2model.contentList.isNotEmpty){
      AppDialogIris.instance.showInfoDialog(
          context,
        null,
           'عنوان محتوا ذکر نشده.',
      );

      return;
    }

    widget.injectData.level2model.title = title;
    widget.injectData.level2model.description = descriptionCtr.text;

    Navigator.of(context).pop();
  }
}
