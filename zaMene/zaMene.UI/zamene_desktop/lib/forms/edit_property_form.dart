import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zamene_desktop/models/city_desktop_model.dart';
import 'package:zamene_desktop/models/country_desktop_model.dart';
import 'package:zamene_desktop/providers/city_provider.dart';
import 'package:zamene_desktop/providers/country_provider.dart';
import 'package:zamene_desktop/providers/property_provider.dart';

class UrediNekretninuForma extends StatefulWidget {
  final Map<String, dynamic> nekretnina;
  final VoidCallback onUpdated;

  const UrediNekretninuForma({
    Key? key,
    required this.nekretnina,
    required this.onUpdated,
  }) : super(key: key);

  @override
  _UrediNekretninuFormaState createState() => _UrediNekretninuFormaState();
}

class _UrediNekretninuFormaState extends State<UrediNekretninuForma> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nazivController;
  late TextEditingController cijenaController;
  late TextEditingController adresaController;
  late TextEditingController opisController;
  late TextEditingController sobeController;
  late TextEditingController kvadraturaController;

  List<File> noveSlike = [];

  final NekretnineService _service = NekretnineService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<CityDesktopModel> gradovi = [];
  CityDesktopModel? odabraniGrad;
  bool ucitavanjeGradova = true;

  List<CountryDesktopModel> drzave = [];
  CountryDesktopModel? odabranaDrzava;
  bool ucitavanjeDrzava = true;

  @override
  void initState() {
    super.initState();

    nazivController = TextEditingController(text: widget.nekretnina['naziv']);
    cijenaController = TextEditingController(
        text: widget.nekretnina['cijena'].toString().replaceAll(' KM', ''));
    adresaController = TextEditingController(text: widget.nekretnina['adresa']);
    opisController = TextEditingController(text: widget.nekretnina['opis']);
    sobeController = TextEditingController(
        text: widget.nekretnina['sobe']?.toString() ?? '');
    kvadraturaController = TextEditingController(
        text: widget.nekretnina['kvadratura']?.toString() ?? '');

    ucitajGradove();
    ucitajDrzave();
  }

  Future<void> ucitajGradove() async {
    try {
      final result = await CityService().fetchGradove();
      final currentGrad = widget.nekretnina['grad'];

      setState(() {
        gradovi = result;
        odabraniGrad = gradovi.firstWhere(
          (c) => c.name.toLowerCase() == currentGrad.toLowerCase(),
          orElse: () => gradovi.first,
        );
        ucitavanjeGradova = false;
      });
    } catch (e) {
      print("Greška prilikom učitavanja gradova: $e");
      setState(() => ucitavanjeGradova = false);
    }
  }

  Future<void> ucitajDrzave() async {
    try {
      final result = await CountryService().fetchCountries();
      final currentDrzava = widget.nekretnina['drzava'];

      setState(() {
        drzave = result;
        odabranaDrzava = drzave.firstWhere(
          (d) => d.name.toLowerCase() == currentDrzava.toLowerCase(),
          orElse: () => drzave.first,
        );
        ucitavanjeDrzava = false;
      });
    } catch (e) {
      print("Greška prilikom učitavanja država: $e");
      setState(() => ucitavanjeDrzava = false);
    }
  }

  Future<void> odaberiNoveSlike() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        noveSlike.addAll(pickedFiles.map((e) => File(e.path)).toList());
      });
    }
  }

  Future<void> posaljiUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await _secureStorage.read(key: "token");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Niste prijavljeni'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final propertyId = widget.nekretnina['id'];

    final fields = {
      'Title': nazivController.text,
      'Description': opisController.text,
      'Price': cijenaController.text,
      'City': odabraniGrad?.name ?? '',
      'Country': odabranaDrzava?.name ?? '',
      'Address': adresaController.text,
      'RoomCount': sobeController.text,
      'Area': kvadraturaController.text,
    };

    bool success = await _service.updateProperty(
      propertyId: propertyId,
      fields: fields,
      newImages: noveSlike,
      deleteImageIds: [],
      token: token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nekretnina uspješno ažurirana'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onUpdated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Greška prilikom ažuriranja'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nazivController.dispose();
    cijenaController.dispose();
    adresaController.dispose();
    opisController.dispose();
    sobeController.dispose();
    kvadraturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Uredi nekretninu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nazivController,
                  decoration: const InputDecoration(labelText: 'Naziv'),
                  validator: (v) => v == null || v.isEmpty ? 'Unesite naziv' : null,
                ),
                TextFormField(
                  controller: cijenaController,
                  decoration: const InputDecoration(labelText: 'Cijena (KM)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite cijenu';
                    if (double.tryParse(v) == null) return 'Neispravan broj';
                    return null;
                  },
                ),
                ucitavanjeGradova
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<CityDesktopModel>(
                        decoration: const InputDecoration(labelText: 'Grad'),
                        value: odabraniGrad,
                        items: gradovi.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(
                              city.name,
                              style: const TextStyle(fontWeight: FontWeight.normal)
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => odabraniGrad = newValue),
                        validator: (value) => value == null ? 'Odaberite grad' : null,
                      ),
                ucitavanjeDrzava
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<CountryDesktopModel>(
                        decoration: const InputDecoration(labelText: 'Država'),
                        value: odabranaDrzava,
                        items: drzave.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(
                              country.name,
                              style: const TextStyle(fontWeight: FontWeight.normal)
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => odabranaDrzava = newValue),
                        validator: (value) => value == null ? 'Odaberite državu' : null,
                      ),
                TextFormField(
                  controller: adresaController,
                  decoration: const InputDecoration(labelText: 'Adresa'),
                  validator: (v) => v == null || v.isEmpty ? 'Unesite adresu' : null,
                ),
                TextFormField(
                  controller: opisController,
                  decoration: const InputDecoration(labelText: 'Opis'),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Unesite opis' : null,
                ),
                TextFormField(
                  controller: sobeController,
                  decoration: const InputDecoration(labelText: 'Broj soba'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite broj soba';
                    if (int.tryParse(v) == null) return 'Neispravan broj';
                    return null;
                  },
                ),
                TextFormField(
                  controller: kvadraturaController,
                  decoration: const InputDecoration(labelText: 'Kvadratura (m²)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite kvadraturu';
                    if (double.tryParse(v) == null) return 'Neispravan broj';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: odaberiNoveSlike,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Dodaj nove slike'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: noveSlike.map((file) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(4),
                            width: 100,
                            height: 100,
                            child: Image.file(file, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => noveSlike.remove(file)),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: posaljiUpdate,
                  child: const Text('Spremi izmjene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
