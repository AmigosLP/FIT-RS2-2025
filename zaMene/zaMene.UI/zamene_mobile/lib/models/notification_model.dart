import 'package:json_annotation/json_annotation.dart';
part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(name: 'notificationID')
  final int? id;

  @JsonKey(name: 'userID')
  final int? userId;

  final String? title;
  final String? message;
  final String? type;
  final String? content;

  @JsonKey(name: 'isRead')
  bool? isRead;

  final int? relatedReservationId;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.content,
    required this.isRead,
    required this.relatedReservationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json)
    => _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
