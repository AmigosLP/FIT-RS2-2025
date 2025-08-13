// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_desktop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryDesktopModel _$CountryDesktopModelFromJson(Map<String, dynamic> json) =>
    CountryDesktopModel(
      countryID: (json['countryID'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$CountryDesktopModelToJson(
  CountryDesktopModel instance,
) => <String, dynamic>{'countryID': instance.countryID, 'name': instance.name};
