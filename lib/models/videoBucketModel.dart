
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:vosate_zehn_panel/models/ExtendedMediaModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class VideoBucketModel {
  int? id;
  String? title;
  String? description;
  MediaModel? imageModel;
  List<ExtendedMediaModel> mediaList = [];

  VideoBucketModel();

  VideoBucketModel.fromMap(Map? map){
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
        final itm = ExtendedMediaModel.fromMap(i);
        mediaList.add(itm);
      }
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.media] = imageModel?.toMap();
    map[Keys.dataList] = mediaList;

    return map;
  }
}
