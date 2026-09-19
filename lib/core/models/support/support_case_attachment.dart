import 'package:json_annotation/json_annotation.dart';

part 'support_case_attachment.g.dart';

@JsonSerializable()
class SupportCaseAttachment {
  final String? id;
  @JsonKey(name: 'case_id')
  final String? caseId;
  @JsonKey(name: 'message_id')
  final String? messageId;
  @JsonKey(name: 'file_name')
  final String? fileName;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @JsonKey(name: 'content_type')
  final String? contentType;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  SupportCaseAttachment({
    this.id,
    this.caseId,
    this.messageId,
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
