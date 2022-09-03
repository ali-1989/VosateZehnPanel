import 'package:app/models/dateFieldMixin.dart';

import 'package:app/system/keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

class AdvertisingModel with DateFieldMixin {
  int? id;
  int? mediaId;
  String? clickUrl;
  String? tag;
  //----------- local
  PlatformFile? platformFile;
  MediaModel? mediaModel;

  AdvertisingModel();

  AdvertisingModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    mediaId = map['media_id'];
    tag = map['tag'];
    clickUrl = map[Keys.url];
    date = DateHelper.tsToSystemDate(map[Keys.date]);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['media_id'] = mediaId;
    map['tag'] = tag;
    map[Keys.url] = clickUrl;
    map[Keys.date] = DateHelper.toTimestampNullable(date);

    return map;
  }
}
