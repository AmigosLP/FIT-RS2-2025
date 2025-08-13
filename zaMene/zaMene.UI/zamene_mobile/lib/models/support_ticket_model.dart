import 'package:json_annotation/json_annotation.dart';

part 'support_ticket_model.g.dart';

@JsonSerializable()
class SupportTicketModel {
  final int supportTicketID;
  final int userID;
  final String subject;
  final String message;
  final String? response;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SupportTicketModel({
    required this.supportTicketID,
    required this.userID,
    required this.subject,
    required this.message,
    this.response,
    required this.isResolved,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketModelToJson(this);
}

@JsonSerializable()
class SupportTicketCreateModel {
  String subject;
  String message;

  SupportTicketCreateModel({required this.subject, required this.message});

  factory SupportTicketCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketCreateModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SupportTicketCreateModelToJson(this);
}

@JsonSerializable()
class SupportTicketUpdateModel {
  bool? isResolved;
  String? response;

  SupportTicketUpdateModel({this.isResolved, this.response});

  factory SupportTicketUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketUpdateModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SupportTicketUpdateModelToJson(this);
}
