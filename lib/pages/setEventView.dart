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
  final DateTime date;
  final String? description;

  const SetEventView({
    required this.date,
    required this.description,
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

    txtCtr.text = widget.description?? '';
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

                    Text(SolarHijriDate.from(widget.date).format('yyyy/MM/dd', 'en')),

                    ElevatedButton(
                        onPressed: (){
                          if(widget.description == txtCtr.text){
                            Navigator.of(context).pop();
                            return;
                          }

                          requestSetDailyText();
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

  void requestSetDailyText(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_daily_text';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['text'] = txtCtr.text;
    js[Keys.date] = DateHelper.toTimestamp(widget.date);

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        Navigator.of(context).pop(txtCtr.text);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.bodyJson = js;
    requester.request(context);
  }
}
