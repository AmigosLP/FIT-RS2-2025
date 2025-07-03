// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homepage_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomepageRecommendationModel _$HomepageRecommendationModelFromJson(
  Map<String, dynamic> json,
) => HomepageRecommendationModel(
  message: json['message'] as String,
  properties:
      (json['properties'] as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$HomepageRecommendationModelToJson(
  HomepageRecommendationModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'properties': instance.properties,
};
