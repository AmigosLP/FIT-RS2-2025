// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) =>
    City(cityID: (json['cityID'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'cityID': instance.cityID,
  'name': instance.name,
};
