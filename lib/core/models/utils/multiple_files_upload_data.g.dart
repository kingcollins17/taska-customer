// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiple_files_upload_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultipleFilesUploadData _$MultipleFilesUploadDataFromJson(
  Map<String, dynamic> json,
) => MultipleFilesUploadData(
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => FileUploadData.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$MultipleFilesUploadDataToJson(
  MultipleFilesUploadData instance,
) => <String, dynamic>{
  'files': instance.files?.map((e) => e.toJson()).toList(),
  'total': instance.total,
};
