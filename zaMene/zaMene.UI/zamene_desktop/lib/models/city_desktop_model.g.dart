// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_desktop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityDesktopModel _$CityDesktopModelFromJson(Map<String, dynamic> json) =>
    CityDesktopModel(
      cityID: (json['cityID'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$CityDesktopModelToJson(CityDesktopModel instance) =>
    <String, dynamic>{'cityID': instance.cityID, 'name': instance.name};
