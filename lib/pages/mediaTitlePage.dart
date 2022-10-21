import 'package:flutter/material.dart';

import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/subBuketModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appSheet.dart';

class MediaTitlePageInjectData {
  late MediaModel mediaModel;
  late SubBucketModel subBucketModel;
}
///----------------------------------------------------------------
class MediaTitlePage extends StatefulWidget {
  final MediaTitlePageInjectData injectData;

  const MediaTitlePage({required this.injectData, Key? key}) : super(key: key);

  @override
  State<MediaTitlePage> createState() => _MediaTitlePageState();
}
///============================================================================================
class _MediaTitlePageState extends StateBase<MediaTitlePage> {
  late Requester requester = Requester();
  TextEditingController titleCtr = TextEditingController();

  @override
  void initState(){
    super.initState();

    titleCtr.text = widget.injectData.mediaModel.title?? '';
  }

  @override
  void dispose() {
    requester.dispose();

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

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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

          SizedBox(height: 20),
          Row(
            children: [
              Text('عنوان رسانه:'),
            ],
          ),

          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: titleCtr,
                  decoration: InputDecoration(
                    hintText: 'عنوان',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          SizedBox(
            width: 110,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: onSaveClick,
              child: Text('ذخیره'),
            ),
          ),
        ],
      ),
    );
  }

  void onSaveClick(){
    requestSave();
  }

  void requestSave(){
    final t = titleCtr.text.trim();

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_media_title';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.mediaModel.id;
    js[Keys.title] = t.isEmpty? null : titleCtr.text;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      widget.injectData.mediaModel.title = t.isEmpty? null : titleCtr.text;

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        Navigator.of(context).pop(true);
      });
    };

    showLoading();
    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }
}
