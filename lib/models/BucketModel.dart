import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn_panel/models/dateFieldMixin.dart';
import 'package:vosate_zehn_panel/models/subBuketModel.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class BucketModel with DateFieldMixin {
  int? id;
  late String title;
  String? description;
  int? mediaId;
  int bucketType = 0;
  //--------------- local
  MediaModel? imageModel;
  List<SubBucketModel> level2List = [];

  BucketModel();

  BucketModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    title = map[Keys.title];
    description = map[Keys.description];
    bucketType = map['bucket_type']?? 0;
    mediaId = map['media_id'];
    date = map[Keys.date];

    /*if(map[Keys.dataList] is List){
      for(final i in map[Keys.dataList]) {
        final itm = Level2Model.fromMap(i);
        level2List.add(itm);
      }
    }*/
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.date] = date;
    map['bucket_type'] = bucketType;
    map['media_id'] = mediaId;

    return map;
  }

  Map<String, dynamic> toMapServer(){
    return JsonHelper.removeNulls(toMap()) as Map<String, dynamic>;
  }
}
