import 'package:json_annotation/json_annotation.dart';

part 'city_model.g.dart';

@JsonSerializable()
class City {
  final int cityID;
  final String name;

  City({
    required this.cityID,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}
