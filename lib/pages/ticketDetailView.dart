import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/models/ticketModel.dart';
import 'package:app/system/extensions.dart';

class TicketDetailView extends StatefulWidget {
  final TicketModel ticketModel;

  const TicketDetailView({
    required this.ticketModel,
    Key? key,
  }) : super(key: key);

  @override
  State<TicketDetailView> createState() => _TicketDetailViewState();
}
///========================================================================================
class _TicketDetailViewState extends State<TicketDetailView> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: MaxWidth(
          maxWidth: 500,
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: ClipOval(
                                child: Builder(
                                    builder: (ctx){
                                      if(widget.ticketModel.senderModel?.profileModel?.url == null){
                                        return SizedBox.expand(child: ColoredBox(color: ColorHelper.textToColor(widget.ticketModel.senderModel?.userName?? '0')));
                                      }

                                      return Image.network(widget.ticketModel.senderModel?.profileModel?.url?? '');
                                    }
                                ),
                              ),
                            ),

                            SizedBox(width: 8,),
                            Text(widget.ticketModel.senderModel?.nameFamily?? '').bold(),
                          ],
                        ),


                        Expanded(child: SizedBox()),
                        ElevatedButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('برگشت')
                        ),
                      ],
                    ),

                    SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('موبایل: ${widget.ticketModel.senderModel?.mobile?? ''}'),
                            SizedBox(height: 8),
                            Text('ایمیل: ${widget.ticketModel.senderModel?.email?? ''}'),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                    Expanded(
                        child: SizedBox.expand(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(8),
                            child: Text(widget.ticketModel.data?? ''),
                          )
                        ).wrapBoxBorder(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}
