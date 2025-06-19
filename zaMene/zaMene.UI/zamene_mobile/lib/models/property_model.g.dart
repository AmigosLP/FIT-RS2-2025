// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) =>
    PropertyModel(
      propertyID: (json['propertyID'] as num).toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      city: json['city'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      address: json['address'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$PropertyModelToJson(PropertyModel instance) =>
    <String, dynamic>{
      'propertyID': instance.propertyID,
      'title': instance.title,
      'description': instance.description,
      'city': instance.city,
      'price': instance.price,
      'address': instance.address,
      'averageRating': instance.averageRating,
      'imageUrls': instance.imageUrls,
    };
