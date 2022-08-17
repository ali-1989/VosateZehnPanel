import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn_panel/models/contentModel.dart';
import 'package:vosate_zehn_panel/models/dateFieldMixin.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class SubBucketModel with DateFieldMixin {
  int? id;
  int? parentId;
  String? title;
  String? description;
  int? coverId;
  int? mediaId;
  int? contentId;
  int duration = 0;
  int type = 0; // 1:video, 2:audio, 10:content list
  int contentType = 0;

  //-------- local
  MediaModel? imageModel;
  List<ContentModel> contentList = [];

  SubBucketModel();

  SubBucketModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    title = map[Keys.title];
    description = map[Keys.description];
    type = map[Keys.type];
    date = DateHelper.tsToSystemDate(map[Keys.date]);
    parentId = map['parent_id'];
    mediaId = map['media_id'];
    coverId = map['cover_id'];
    contentId = map['content_id'];
    contentType = map['content_type'];
    duration = map['duration'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.type] = type;
    map['parent_id'] = parentId;
    map['cover_id'] = coverId;
    map['media_id'] = mediaId;
    map['content_type'] = contentType;

    if(id != null){
      map[Keys.id] = id;
    }

    if(date != null){
      map[Keys.date] = DateHelper.toTimestampNullable(date);
    }

    if(duration > 0){
      map['duration'] = duration;
    }

    return map;
  }
}
