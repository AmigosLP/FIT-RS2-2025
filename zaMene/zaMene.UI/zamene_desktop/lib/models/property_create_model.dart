import 'dart:io';
import 'package:http/http.dart' as http;

class PropertyCreateModel {
  final String title;
  final String description;
  final double price;
  final String address;
  final String city;
  final String country;
  final int agentId;
  final int roomCount;
  final double area;
  final List<File> images;

  PropertyCreateModel({
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.city,
    required this.country,
    required this.agentId,
    required this.roomCount,
    required this.area,
    required this.images,
  });

  Future<void> dodaj(http.MultipartRequest request) async {
    request.fields['Title'] = title;
    request.fields['Description'] = description;
    request.fields['Price'] = price.toString();
    request.fields['Address'] = address;
    request.fields['City'] = city;
    request.fields['Country'] = country;
    request.fields['AgentID'] = agentId.toString();
    request.fields['RoomCount'] = roomCount.toString();
    request.fields['Area'] = area.toString();

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }
  }
}
