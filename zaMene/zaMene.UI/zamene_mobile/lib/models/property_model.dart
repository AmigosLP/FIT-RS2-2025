import 'package:json_annotation/json_annotation.dart';
part 'property_model.g.dart';

@JsonSerializable()
class PropertyModel {
  final int propertyID;
  final String title;
  final String city;
  final double price;
  final String address;
  double? averageRating;
  final List<String>? imageUrls;

  PropertyModel({
    required this.propertyID,
    required this.title,
    required this.city,
    required this.price,
    required this.address,
    required this.averageRating,
    required this.imageUrls
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
}