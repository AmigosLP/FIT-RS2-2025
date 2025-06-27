// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyStatisticsModel _$PropertyStatisticsModelFromJson(
  Map<String, dynamic> json,
) => PropertyStatisticsModel(
  propertyID: (json['propertyID'] as num).toInt(),
  title: json['title'] as String,
  city: json['city'] as String,
  totalReservation: (json['totalReservation'] as num).toInt(),
  averageRating: (json['averageRating'] as num).toDouble(),
  viewCount: (json['viewCount'] as num).toInt(),
  isTopProperty: json['isTopProperty'] as bool,
);

Map<String, dynamic> _$PropertyStatisticsModelToJson(
  PropertyStatisticsModel instance,
) => <String, dynamic>{
  'propertyID': instance.propertyID,
  'title': instance.title,
  'city': instance.city,
  'totalReservation': instance.totalReservation,
  'averageRating': instance.averageRating,
  'viewCount': instance.viewCount,
  'isTopProperty': instance.isTopProperty,
};
