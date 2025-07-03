import 'package:json_annotation/json_annotation.dart';
part 'my_reservations_model.g.dart';

@JsonSerializable()
class MyReservations {
  final int reservationID;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int propertyID;
  final String propertyTitle;
  final String propertyCity;
  final double propertyPrice;
  final List<String> propertyImageUrls;
  final String propertyDescription;
  final String? propertyAgentName;
  final String? propertyAgentPhone;

  MyReservations({
    required this.reservationID,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.propertyID,
    required this.propertyTitle,
    required this.propertyCity,
    required this.propertyPrice,
    required this.propertyImageUrls,
    required this.propertyDescription,
    this.propertyAgentName,
    this.propertyAgentPhone,
  });

  factory MyReservations.fromJson(Map<String, dynamic> json) => _$MyReservationsFromJson(json);

  Map<String, dynamic> toJson() => _$MyReservationsToJson(this);
}
