
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:vosate_zehn_panel/models/Level2Model.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class FocusBucketModel {
  int? id;
  String? title;
  String? description;
  MediaModel? imageModel;
  List<Level2Model> level2List = [];

  FocusBucketModel();

  FocusBucketModel.fromMap(Map? map){
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
        final itm = Level2Model.fromMap(i);
        level2List.add(itm);
      }
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.media] = imageModel?.toMap();
    map[Keys.dataList] = level2List;

    return map;
  }
}
