import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn_panel/models/dateFieldMixin.dart';
import 'package:vosate_zehn_panel/models/speakerModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class ContentModel with DateFieldMixin {
  int? id;
  //int? type;
  int? speakerId;
  List<int> mediaIds = [];
  //------------- local
  SpeakerModel? speakerModel;
  List<MediaModel> mediaList = [];

  ContentModel();

  ContentModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    speakerId = map['speaker_id'];
    mediaList = map['media_ids'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['speaker_id'] = speakerId;
    map['media_ids'] = mediaList;

    return map;
  }
}
