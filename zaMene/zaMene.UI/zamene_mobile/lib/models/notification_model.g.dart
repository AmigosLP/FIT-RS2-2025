// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['notificationID'] as num?)?.toInt(),
      userId: (json['userID'] as num?)?.toInt(),
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as String?,
      content: json['content'] as String?,
      isRead: json['isRead'] as bool?,
      relatedReservationId: (json['relatedReservationId'] as num?)?.toInt(),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'notificationID': instance.id,
      'userID': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'content': instance.content,
      'isRead': instance.isRead,
      'relatedReservationId': instance.relatedReservationId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
