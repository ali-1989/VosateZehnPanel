
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:vosate_zehn_panel/models/contentModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class Level2Model {
  int? id;
  String? title;
  String? description;
  String? url;
  MediaModel? imageModel;
  int duration = 0;
  int type = 0; // 1:video, 2:audio, 10:content list
  int contentType = 0;
  List<ContentModel> contentList = [];

  Level2Model();

  Level2Model.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    title = map[Keys.title];
    description = map[Keys.description];

    if(map[Keys.media] is Map){
      imageModel = MediaModel.fromMap(map[Keys.media]);
    }

    if(map[Keys.dataList] is List){
      for(final i in map[Keys.dataList]) {
        final itm = ContentModel.fromMap(i);
        contentList.add(itm);
      }
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.media] = imageModel?.toMap();
    map[Keys.dataList] = contentList;

    return map;
  }
}
