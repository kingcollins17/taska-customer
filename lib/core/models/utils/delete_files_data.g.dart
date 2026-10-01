// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_files_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteFileResult _$DeleteFileResultFromJson(Map<String, dynamic> json) =>
    DeleteFileResult(
      fileUrl: json['file_url'] as String?,
      success: json['success'] as bool?,
    );

Map<String, dynamic> _$DeleteFileResultToJson(DeleteFileResult instance) =>
    <String, dynamic>{
      'file_url': instance.fileUrl,
      'success': instance.success,
    };

DeleteFilesData _$DeleteFilesDataFromJson(Map<String, dynamic> json) =>
    DeleteFilesData(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => DeleteFileResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      deletedCount: (json['deleted_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DeleteFilesDataToJson(DeleteFilesData instance) =>
    <String, dynamic>{
      'results': instance.results?.map((e) => e.toJson()).toList(),
      'deleted_count': instance.deletedCount,
    };
