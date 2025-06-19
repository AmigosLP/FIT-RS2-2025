import 'package:json_annotation/json_annotation.dart';
part 'property_model.g.dart';

@JsonSerializable()
class PropertyModel {
  final int propertyID;
  final String? title;
  final String? description;
  final String? city;
  final double? price;
  final String? address;
  double? averageRating;
  final List<String>? imageUrls;

  PropertyModel({
    required this.propertyID,
    this.title,
    this.description,
    this.city,
    this.price,
    this.address,
    this.averageRating,
    this.imageUrls
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
}