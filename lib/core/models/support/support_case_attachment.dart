import 'package:json_annotation/json_annotation.dart';

part 'support_case_attachment.g.dart';

@JsonSerializable()
class SupportCaseAttachment {
  final String? id;
  @JsonKey(name: 'case_id')
  final String? caseId;
  @JsonKey(name: 'message_id')
  final String? messageId;
  @JsonKey(name: 'uploaded_by')
  final String? uploadedBy;
  @JsonKey(name: 'storage_key')
  final String? storageKey;

  @JsonKey(name: 'file_name', readValue: _readFileName)
  final String? fileName;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(name: 'file_size', readValue: _readFileSize)
  final int? fileSize;
  @JsonKey(name: 'content_type', readValue: _readContentType)
  final String? contentType;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  static Object? _readFileName(Map json, String key) =>
      json['filename'] ?? json['file_name'];

  static Object? _readFileSize(Map json, String key) =>
      json['size'] ?? json['file_size'];

  static Object? _readContentType(Map json, String key) =>
      json['mime_type'] ?? json['content_type'];

  SupportCaseAttachment({
    this.id,
    this.caseId,
    this.messageId,
    this.uploadedBy,
    this.storageKey,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.contentType,
    this.createdAt,
  });

  factory SupportCaseAttachment.fromJson(Map<String, dynamic> json) =>
      _$SupportCaseAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$SupportCaseAttachmentToJson(this);
}
