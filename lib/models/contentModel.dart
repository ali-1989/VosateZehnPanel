
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:vosate_zehn_panel/models/speakerModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class ContentModel {
  int? id;
  late SpeakerModel speakerModel;
  List<MediaModel> mediaList = [];
  int? type;

  ContentModel();

  ContentModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    type = map[Keys.type];
    speakerModel = SpeakerModel.fromMap(map['speaker']);

    final List mList = map[Keys.dataList]?? [];

    for(final m in mList){
      mediaList.add(MediaModel.fromMap(m));
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.type] = type;
    map['speaker'] = speakerModel.toMap();
    map[Keys.dataList] = mediaList;

    return map;
  }
}