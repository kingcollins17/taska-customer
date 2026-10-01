import 'package:json_annotation/json_annotation.dart';

part 'delete_files_request.g.dart';

@JsonSerializable()
class DeleteFilesRequest {
  @JsonKey(name: 'file_urls')
  final List<String> fileUrls;

  DeleteFilesRequest({required this.fileUrls});

  factory DeleteFilesRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteFilesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteFilesRequestToJson(this);
}
