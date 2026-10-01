import 'package:json_annotation/json_annotation.dart';
import 'file_upload_data.dart';

part 'multiple_files_upload_data.g.dart';

@JsonSerializable(explicitToJson: true)
class MultipleFilesUploadData {
  final List<FileUploadData>? files;
  final int? total;

  MultipleFilesUploadData({this.files, this.total});

  factory MultipleFilesUploadData.fromJson(Map<String, dynamic> json) =>
      _$MultipleFilesUploadDataFromJson(json);

  Map<String, dynamic> toJson() => _$MultipleFilesUploadDataToJson(this);
}
