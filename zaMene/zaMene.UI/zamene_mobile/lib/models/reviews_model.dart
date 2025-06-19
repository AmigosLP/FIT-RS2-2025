import 'package:json_annotation/json_annotation.dart';
part 'reviews_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final int reviewID;
  final int userID;
  final int propertyID;
  final int rating;
  final String comment;
  final String userFullName;
  final String? userProfileImageUrl;
  final DateTime reviewDate;

  ReviewModel({
    required this.reviewID,
    required this.userID,
    required this.propertyID,
    required this.rating,
    required this.comment,
    required this.userFullName,
    this.userProfileImageUrl,
    required this.reviewDate,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>_$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
