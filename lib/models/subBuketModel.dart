import 'package:file_picker/file_picker.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn_panel/models/contentModel.dart';
import 'package:vosate_zehn_panel/models/dateFieldMixin.dart';
import 'package:vosate_zehn_panel/system/keys.dart';

class SubBucketModel with DateFieldMixin {
  int? id;
  int? bucketId;
  String? title;
  String? description;
  String? url;
  int? mediaId;
  int duration = 0;
  int type = 0; // 1:video, 2:audio, 10:content list
  int contentType = 0;

  //-------- local
  MediaModel? imageModel;
  List<ContentModel> contentList = [];
  //PlatformFile? pickedFile;
  //List<PlatformFile> pickedFiles = [];

  SubBucketModel();

  SubBucketModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    title = map[Keys.title];
    description = map[Keys.description];
    type = map[Keys.type];
    date = map[Keys.date];
    bucketId = map['bucket_id'];
    mediaId = map['media_id'];
    contentType = map['content_type'];
    duration = map['duration'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.type] = type;
    map[Keys.date] = date;
    map['bucket_id'] = bucketId;
    map['media_id'] = mediaId;
    map['content_type'] = contentType;
    map['duration'] = duration;

    return map;
  }
}
