import 'package:flutter/material.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:app/system/extensions.dart';

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
class _SetEventViewState extends State<SetEventView> {
  TextEditingController txtCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    txtCtr.text = widget.description?? '';
  }

  @override
  void dispose() {
    txtCtr.dispose();

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
                          Navigator.of(context).pop(txtCtr.text);
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


}
