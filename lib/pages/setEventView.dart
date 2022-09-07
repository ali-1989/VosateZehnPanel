import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appSheet.dart';

class SetEventView extends StatefulWidget {
  final CalendarEventData event;

  const SetEventView({
    required this.event,
    Key? key,
  }) : super(key: key);

  @override
  State<SetEventView> createState() => _SetEventViewState();
}
///=====================================================================
class _SetEventViewState extends StateBase<SetEventView> {
  TextEditingController txtCtr = TextEditingController();
  Requester requester = Requester();

  @override
  void initState() {
    super.initState();

    txtCtr.text = widget.event.description;
  }

  @override
  void dispose() {
    txtCtr.dispose();
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return MaxWidth(
      maxWidth: 500,
      child: SizedBox.expand(
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(),

                    Text(SolarHijriDate.from(widget.event.date).format('yyyy/MM/dd', 'en')),

                    ElevatedButton(
                        onPressed: (){
                          if(widget.event.description == txtCtr.text){
                            Navigator.of(context).pop();
                            return;
                          }

                          if(txtCtr.text.trim().isEmpty){
                            if(widget.event.event == null){
                              Navigator.of(context).pop();
                            }
                            else {
                              requestDeleteDailyText();
                            }
                          }
                          else {
                            requestSetDailyText();
                          }
                        },
                        child: Text('ذخیره')
                    ),
                  ],
                ),

                SizedBox(height: 12,),

                TextField(
                  controller: txtCtr,
                  minLines: 8,
                  maxLines: 12,
                ).wrapBoxBorder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void requestDeleteDailyText(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_daily_text';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.event.event as int?;
    js[Keys.date] = DateHelper.toTimestamp(widget.event.date);

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        final res = CalendarEventData(
          date: widget.event.date,
          description: '',
          title: '',
        );

        Navigator.of(context).pop(res);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.bodyJson = js;
    requester.request(context);
  }

  void requestSetDailyText(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_daily_text';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.event.event as int?;
    js['text'] = txtCtr.text;
    js[Keys.date] = DateHelper.toTimestamp(widget.event.date);

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final id = data[Keys.id];

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        final res = CalendarEventData(
          date: widget.event.date,
          description: txtCtr.text,
          event: id,
          title: '',
        );

        Navigator.of(context).pop(res);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.bodyJson = js;
    requester.request(context);
  }
}
