// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  reviewID: (json['reviewID'] as num).toInt(),
  userID: (json['userID'] as num).toInt(),
  propertyID: (json['propertyID'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  userFullName: json['userFullName'] as String,
  userProfileImageUrl: json['userProfileImageUrl'] as String?,
  reviewDate: DateTime.parse(json['reviewDate'] as String),
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'reviewID': instance.reviewID,
      'userID': instance.userID,
      'propertyID': instance.propertyID,
      'rating': instance.rating,
      'comment': instance.comment,
      'userFullName': instance.userFullName,
      'userProfileImageUrl': instance.userProfileImageUrl,
      'reviewDate': instance.reviewDate.toIso8601String(),
    };
