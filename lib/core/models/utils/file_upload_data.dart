import 'package:json_annotation/json_annotation.dart';

part 'file_upload_data.g.dart';

@JsonSerializable()
class FileUploadData {
  final String? filename;
  final String? url;

  FileUploadData({this.filename, this.url});

  factory FileUploadData.fromJson(Map<String, dynamic> json) =>
      _$FileUploadDataFromJson(json);

  Map<String, dynamic> toJson() => _$FileUploadDataToJson(this);
}
