// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_reservations_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyReservations _$MyReservationsFromJson(Map<String, dynamic> json) =>
    MyReservations(
      reservationID: (json['reservationID'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      propertyID: (json['propertyID'] as num).toInt(),
      propertyTitle: json['propertyTitle'] as String,
      propertyCity: json['propertyCity'] as String,
      propertyPrice: (json['propertyPrice'] as num).toDouble(),
      propertyImageUrls:
          (json['propertyImageUrls'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      propertyDescription: json['propertyDescription'] as String,
      propertyAgentName: json['propertyAgentName'] as String?,
      propertyAgentPhone: json['propertyAgentPhone'] as String?,
    );

Map<String, dynamic> _$MyReservationsToJson(MyReservations instance) =>
    <String, dynamic>{
      'reservationID': instance.reservationID,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'propertyID': instance.propertyID,
      'propertyTitle': instance.propertyTitle,
      'propertyCity': instance.propertyCity,
      'propertyPrice': instance.propertyPrice,
      'propertyImageUrls': instance.propertyImageUrls,
      'propertyDescription': instance.propertyDescription,
      'propertyAgentName': instance.propertyAgentName,
      'propertyAgentPhone': instance.propertyAgentPhone,
    };
