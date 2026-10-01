import 'package:json_annotation/json_annotation.dart';

part 'delete_files_data.g.dart';

@JsonSerializable()
class DeleteFileResult {
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  final bool? success;

  DeleteFileResult({this.fileUrl, this.success});

  factory DeleteFileResult.fromJson(Map<String, dynamic> json) =>
      _$DeleteFileResultFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteFileResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DeleteFilesData {
  final List<DeleteFileResult>? results;
  @JsonKey(name: 'deleted_count')
  final int? deletedCount;

  DeleteFilesData({this.results, this.deletedCount});

  factory DeleteFilesData.fromJson(Map<String, dynamic> json) =>
      _$DeleteFilesDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteFilesDataToJson(this);
}
