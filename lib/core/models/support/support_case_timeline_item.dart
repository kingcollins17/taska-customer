import 'package:json_annotation/json_annotation.dart';

part 'support_case_timeline_item.g.dart';

@JsonSerializable()
class SupportCaseTimelineItem {
  final String? id;
  @JsonKey(name: 'item_type')
  final String? itemType;
  final DateTime? timestamp;
  final String? title;
  final String? description;
  @JsonKey(name: 'actor_type')
  final String? actorType;
  @JsonKey(name: 'actor_id')
  final String? actorId;
  final Map<String, dynamic>? metadata;

  SupportCaseTimelineItem({
    this.id,
    this.itemType,
    this.timestamp,
    this.title,
    this.description,
    this.actorType,
    this.actorId,
    this.metadata,
  });

  factory SupportCaseTimelineItem.fromJson(Map<String, dynamic> json) =>
      _$SupportCaseTimelineItemFromJson(json);

  Map<String, dynamic> toJson() => _$SupportCaseTimelineItemToJson(this);
}
