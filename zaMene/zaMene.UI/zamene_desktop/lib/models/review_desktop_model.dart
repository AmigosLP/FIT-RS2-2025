
import 'package:json_annotation/json_annotation.dart';
part 'review_desktop_model.g.dart';

@JsonSerializable()
class ReviewDesktopModel {
  final int reviewID;
  final String? userFullName;
  final String? comment;
  final int rating;
  final DateTime reviewDate;
  final String? propertyName;
  final String? description;
  final int price;
  final String? address;  

  ReviewDesktopModel({
    required this.reviewID,
    required this.userFullName,
    required this.comment,
    required this.rating,
    required this.reviewDate,
    required this.propertyName,
    required this.description,
    required this.price,
    required this.address
  });

    factory ReviewDesktopModel.fromJson(Map<String, dynamic> json) => _$ReviewDesktopModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDesktopModelToJson(this);
}