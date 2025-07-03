import 'package:json_annotation/json_annotation.dart';
import 'property_model.dart';

part 'homepage_recommendation_model.g.dart';

@JsonSerializable()
class HomepageRecommendationModel {
  final String message;
  final List<PropertyModel> properties;

  HomepageRecommendationModel({
    required this.message,
    required this.properties,
  });

  factory HomepageRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$HomepageRecommendationModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomepageRecommendationModelToJson(this);
}
