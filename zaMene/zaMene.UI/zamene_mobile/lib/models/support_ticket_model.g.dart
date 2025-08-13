// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTicketModel _$SupportTicketModelFromJson(Map<String, dynamic> json) =>
    SupportTicketModel(
      supportTicketID: (json['supportTicketID'] as num).toInt(),
      userID: (json['userID'] as num).toInt(),
      subject: json['subject'] as String,
      message: json['message'] as String,
      response: json['response'] as String?,
      isResolved: json['isResolved'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt:
          json['resolvedAt'] == null
              ? null
              : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$SupportTicketModelToJson(SupportTicketModel instance) =>
    <String, dynamic>{
      'supportTicketID': instance.supportTicketID,
      'userID': instance.userID,
      'subject': instance.subject,
      'message': instance.message,
      'response': instance.response,
      'isResolved': instance.isResolved,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

SupportTicketCreateModel _$SupportTicketCreateModelFromJson(
  Map<String, dynamic> json,
) => SupportTicketCreateModel(
  subject: json['subject'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$SupportTicketCreateModelToJson(
  SupportTicketCreateModel instance,
) => <String, dynamic>{
  'subject': instance.subject,
  'message': instance.message,
};

SupportTicketUpdateModel _$SupportTicketUpdateModelFromJson(
  Map<String, dynamic> json,
) => SupportTicketUpdateModel(
  isResolved: json['isResolved'] as bool?,
  response: json['response'] as String?,
);

Map<String, dynamic> _$SupportTicketUpdateModelToJson(
  SupportTicketUpdateModel instance,
) => <String, dynamic>{
  'isResolved': instance.isResolved,
  'response': instance.response,
};
