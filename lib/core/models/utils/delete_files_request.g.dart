// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_files_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteFilesRequest _$DeleteFilesRequestFromJson(Map<String, dynamic> json) =>
    DeleteFilesRequest(
      fileUrls: (json['file_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DeleteFilesRequestToJson(DeleteFilesRequest instance) =>
    <String, dynamic>{'file_urls': instance.fileUrls};
