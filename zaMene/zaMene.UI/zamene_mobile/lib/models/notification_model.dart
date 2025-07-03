import 'package:json_annotation/json_annotation.dart';
part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
   @JsonKey(name: "NotificationID")
  final int? notificationID;
  final int? userId;
  final String? title;
  final String? message;
  final String? type;
  final String? content;
  bool? isRead;
  final int? relatedReservationId;
  final DateTime? createdAt;

  NotificationModel({
    required this.notificationID,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.content,
    required this.isRead,
    required this.relatedReservationId,
    required this.createdAt,
  });

    factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}