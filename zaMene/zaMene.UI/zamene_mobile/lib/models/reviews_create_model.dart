import 'package:json_annotation/json_annotation.dart';
part 'reviews_create_model.g.dart';

@JsonSerializable()
class ReviewCreateModel {
  final int userID;
  final int propertyID;
  final int rating;
  final String comment;

  ReviewCreateModel({
    required this.userID,
    required this.propertyID,
    required this.rating,
    required this.comment,
  });

  factory ReviewCreateModel.fromJson(Map<String, dynamic> json) => _$ReviewCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewCreateModelToJson(this);
}
