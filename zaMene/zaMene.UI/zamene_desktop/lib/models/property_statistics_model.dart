
import 'package:json_annotation/json_annotation.dart';
part 'property_statistics_model.g.dart';

@JsonSerializable()
class PropertyStatisticsModel {
  final int propertyID;
  final String title;
  final String city;
  final int totalReservation;
  final double averageRating;
  final int viewCount;
  final bool isTopProperty;


  PropertyStatisticsModel({
    required this.propertyID,
    required this.title,
    required this.city,
    required this.totalReservation,
    required this.averageRating,
    required this.viewCount,
    required this.isTopProperty,
  });

  factory PropertyStatisticsModel.fromJson(Map<String, dynamic> json) => _$PropertyStatisticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyStatisticsModelToJson(this);
}