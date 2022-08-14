
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class ExtendedMediaModel extends MediaModel {
  String? description;

  ExtendedMediaModel();

  ExtendedMediaModel.fromMap(Map map) : super.fromMap(map){
    /*if(map == null) {
      return;
    }*/
    description = map[Keys.description];
  }

  @override
  Map<String, dynamic> toMap(){
    final map = super.toMap();

    map[Keys.description] = description;

    return map;
  }
}
