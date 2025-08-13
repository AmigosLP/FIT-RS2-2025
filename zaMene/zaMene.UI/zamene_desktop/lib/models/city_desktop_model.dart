import 'package:json_annotation/json_annotation.dart';
part 'city_desktop_model.g.dart';

@JsonSerializable()
class CityDesktopModel {
  final int cityID;
  final String name;

  CityDesktopModel({
    required this.cityID,
    required this.name,
  });

  factory CityDesktopModel.fromJson(Map<String, dynamic> json) => _$CityDesktopModelFromJson(json);

  Map<String, dynamic> toJson() => _$CityDesktopModelToJson(this);
}
