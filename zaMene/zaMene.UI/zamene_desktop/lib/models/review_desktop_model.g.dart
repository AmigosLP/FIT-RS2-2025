// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_desktop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDesktopModel _$ReviewDesktopModelFromJson(Map<String, dynamic> json) =>
    ReviewDesktopModel(
      reviewID: (json['reviewID'] as num).toInt(),
      userFullName: json['userFullName'] as String?,
      comment: json['comment'] as String?,
      rating: (json['rating'] as num).toInt(),
      reviewDate: DateTime.parse(json['reviewDate'] as String),
      propertyName: json['propertyName'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$ReviewDesktopModelToJson(ReviewDesktopModel instance) =>
    <String, dynamic>{
      'reviewID': instance.reviewID,
      'userFullName': instance.userFullName,
      'comment': instance.comment,
      'rating': instance.rating,
      'reviewDate': instance.reviewDate.toIso8601String(),
      'propertyName': instance.propertyName,
      'description': instance.description,
      'price': instance.price,
      'address': instance.address,
    };
