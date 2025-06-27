import 'package:json_annotation/json_annotation.dart';
part 'reservation_paypal_model.g.dart';

@JsonSerializable()
class ReservationPaymentModel {
  final int propertyID;
  final int userID;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  ReservationPaymentModel({
    required this.propertyID,
    required this.userID,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  factory ReservationPaymentModel.fromJson(Map<String, dynamic> json) => _$ReservationPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationPaymentModelToJson(this);
}