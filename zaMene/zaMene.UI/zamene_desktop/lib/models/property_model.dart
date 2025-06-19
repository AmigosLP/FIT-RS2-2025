class PropertyModel {
  final String naziv;
  final String cijena;
  final String slika;
  final String spavaceSobe;
  final String toalet;
  final String grad;

  PropertyModel({
    required this.naziv,
    required this.cijena,
    required this.slika,
    required this.spavaceSobe,
    required this.toalet,
    required this.grad,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      naziv: json['naziv'],
      cijena: json['cijena'],
      slika: json['slika'],
      spavaceSobe: json['spavaceSobe'].toString(),
      toalet: json['toalet'].toString(),
      grad: json['grad'],
    );
  }
}
