// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_case_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportCaseAttachment _$SupportCaseAttachmentFromJson(
  Map<String, dynamic> json,
) => SupportCaseAttachment(
  id: json['id'] as String?,
  caseId: json['case_id'] as String?,
  messageId: json['message_id'] as String?,
  uploadedBy: json['uploaded_by'] as String?,
  storageKey: json['storage_key'] as String?,
  fileName: SupportCaseAttachment._readFileName(json, 'file_name') as String?,
  fileUrl: json['file_url'] as String?,
  fileSize: (SupportCaseAttachment._readFileSize(json, 'file_size') as num?)
      ?.toInt(),
  contentType:
      SupportCaseAttachment._readContentType(json, 'content_type') as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SupportCaseAttachmentToJson(
  SupportCaseAttachment instance,
) => <String, dynamic>{
  'id': instance.id,
  'case_id': instance.caseId,
  'message_id': instance.messageId,
  'uploaded_by': instance.uploadedBy,
  'storage_key': instance.storageKey,
  'file_name': instance.fileName,
  'file_url': instance.fileUrl,
  'file_size': instance.fileSize,
  'content_type': instance.contentType,
  'created_at': instance.createdAt?.toIso8601String(),
};
