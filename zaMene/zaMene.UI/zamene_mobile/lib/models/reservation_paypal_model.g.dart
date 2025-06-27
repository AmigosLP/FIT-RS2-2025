// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_paypal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationPaymentModel _$ReservationPaymentModelFromJson(
  Map<String, dynamic> json,
) => ReservationPaymentModel(
  propertyID: (json['propertyID'] as num).toInt(),
  userID: (json['userID'] as num).toInt(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalPrice: (json['totalPrice'] as num).toDouble(),
);

Map<String, dynamic> _$ReservationPaymentModelToJson(
  ReservationPaymentModel instance,
) => <String, dynamic>{
  'propertyID': instance.propertyID,
  'userID': instance.userID,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'totalPrice': instance.totalPrice,
};
