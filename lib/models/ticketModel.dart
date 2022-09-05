import 'package:app/models/customerModel.dart';
import 'package:app/models/mixin/dateFieldMixin.dart';
import 'package:app/system/keys.dart';

class TicketModel with DateFieldMixin {
  int? id;
  String? senderId;
  String? data;
  String? sendDate;
  //----------- local
  CustomerModel? senderModel;

  TicketModel();

  TicketModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    senderId = map['sender_user_id']?.toString();
    data = map[Keys.data];
    sendDate = map['send_date'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['sender_user_id'] = senderId;
    map[Keys.data] = data;
    map['send_date'] = sendDate;

    return map;
  }
}
