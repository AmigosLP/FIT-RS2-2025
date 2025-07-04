// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
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
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'content': instance.content,
      'isRead': instance.isRead,
      'relatedReservationId': instance.relatedReservationId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
