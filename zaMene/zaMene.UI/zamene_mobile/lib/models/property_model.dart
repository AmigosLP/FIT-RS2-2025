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
  final String? agentFullName;
  final String? agentProfileImageUrl;
  final String? agentPhoneNumber;

  PropertyModel({
    required this.propertyID,
    this.title,
    this.description,
    this.city,
    this.price,
    this.address,
    this.averageRating,
    this.imageUrls,
    this.agentFullName,
    this.agentProfileImageUrl,
    this.agentPhoneNumber,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
}