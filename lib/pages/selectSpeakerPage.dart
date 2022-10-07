import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/speakerModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';

class SelectSpeakerPage extends StatefulWidget {
  const SelectSpeakerPage({Key? key}) : super(key: key);

  @override
  State<SelectSpeakerPage> createState() => _SelectSpeakerPageState();
}
///============================================================================================
class _SelectSpeakerPageState extends StateBase<SelectSpeakerPage> {
  late Requester requester = Requester();
  List<SpeakerModel> speakerList = [];
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestData();
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

  Widget buildBody(){
    return Scrollbar(
      trackVisibility: true,
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('انتخاب گوینده').bold()
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      child: Text('برگشت'),
                    ),
                  )
                ],
              ),

              LayoutBuilder(
                builder: (ctx, siz) {
                  if(isInLoadData){
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if(!assistCtr.hasState(state$fetchData)){
                    return SizedBox(
                      height: 200,
                        child: Center(child: NotFetchData(tryClick: tryClick,))
                    );
                  }

                  if(speakerList.isEmpty){
                    return SizedBox(
                      height: 200,
                        child: Center(child: EmptyData())
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: speakerList.length,
                    itemBuilder: (ctx, idx){
                      return buildListItem(idx);
                    },
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListItem(int idx){
    final itm = speakerList[idx];

    return SizedBox(
      key: ValueKey(itm.id),
      height: 80,
      child: InkWell(
        onTap: (){
          onSelectItem(itm);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Builder(
                    builder: (ctx){
                      if(itm.profileModel != null){
                        return Image.network(itm.profileModel!.url!, width: 85, fit: BoxFit.fill,);
                      }

                      return Image.asset(AppImages.appIcon, width: 85, fit: BoxFit.fill);
                    },
                  ),
                ),

                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itm.name).bold(),

                      SizedBox(height: 5),
                      Text(itm.description?? '').alpha(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void tryClick(){
    requestData();
    assistCtr.updateMain();
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void requestData(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_speaker_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    //js[Keys.searchFilter] = searchFilter.toMap();

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final dList = data['speaker_list'];
      final mList = data['media_list'];

      MediaManager.addItemsFromMap(mList);

      for(final k in dList){
        final b = SpeakerModel.fromMap(k);
        b.profileModel = MediaManager.getById(b.mediaId);

        speakerList.add(b);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context);
  }

  void onSelectItem(SpeakerModel itm) {
    Navigator.of(context).pop(itm);
  }
}
