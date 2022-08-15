import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn_panel/system/keys.dart';

class SpeakerModel {
  int? id;
  String? name;
  String? description;
  int? mediaId;
  //----------- local
  MediaModel? imageModel;

  SpeakerModel();

  SpeakerModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    name = map[Keys.name];
    description = map[Keys.description];
    mediaId = map['media_id'];

  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.name] = name;
    map[Keys.description] = description;
    map['media_id'] = mediaId;

    return map;
  }
}
