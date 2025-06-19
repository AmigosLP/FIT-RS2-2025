// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewCreateModel _$ReviewCreateModelFromJson(Map<String, dynamic> json) =>
    ReviewCreateModel(
      userID: (json['userID'] as num).toInt(),
      propertyID: (json['propertyID'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$ReviewCreateModelToJson(ReviewCreateModel instance) =>
    <String, dynamic>{
      'userID': instance.userID,
      'propertyID': instance.propertyID,
      'rating': instance.rating,
      'comment': instance.comment,
    };
