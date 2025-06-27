import 'package:json_annotation/json_annotation.dart';

part 'reservation_model.g.dart';

@JsonSerializable()
class ReservationModel {
  final int propertyID;
  final int userID;
  final DateTime startDate;
  final DateTime endDate;

  ReservationModel({
    required this.propertyID,
    required this.userID,
    required this.startDate,
    required this.endDate,
  });
    factory ReservationModel.fromJson(Map<String, dynamic> json) => _$ReservationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationModelToJson(this);

}