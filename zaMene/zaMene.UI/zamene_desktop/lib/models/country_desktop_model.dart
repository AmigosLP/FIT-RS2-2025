import 'package:json_annotation/json_annotation.dart';
part 'country_desktop_model.g.dart';

@JsonSerializable()
class CountryDesktopModel {
  final int countryID;
  final String name;

  CountryDesktopModel({
    required this.countryID,
    required this.name,
  });

  factory CountryDesktopModel.fromJson(Map<String, dynamic> json) =>_$CountryDesktopModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountryDesktopModelToJson(this);
}
