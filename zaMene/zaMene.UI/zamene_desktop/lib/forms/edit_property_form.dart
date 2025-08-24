import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:zamene_desktop/models/city_desktop_model.dart';
import 'package:zamene_desktop/models/country_desktop_model.dart';
import 'package:zamene_desktop/providers/city_provider.dart';
import 'package:zamene_desktop/providers/country_provider.dart';
import 'package:zamene_desktop/providers/property_provider.dart';

class UrediNekretninuForma extends StatefulWidget {
  final Map<String, dynamic> nekretnina;
  final VoidCallback onUpdated;

  const UrediNekretninuForma({
    super.key,
    required this.nekretnina,
    required this.onUpdated,
  });

  @override
  State<UrediNekretninuForma> createState() => _UrediNekretninuFormaState();
}

class _UrediNekretninuFormaState extends State<UrediNekretninuForma> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nazivController;
  late TextEditingController cijenaController;
  late TextEditingController adresaController;
  late TextEditingController opisController;
  late TextEditingController sobeController;
  late TextEditingController kvadraturaController;

  final _secureStorage = const FlutterSecureStorage();
  final _service = NekretnineService();

  static const int _maxTotalImages = 14;

  final List<_ExistingImage> _postojeceSlike = [];
  final List<int> _deletedImageIds = [];

  final List<File> _noveSlike = [];

  List<CityDesktopModel> gradovi = [];
  CityDesktopModel? odabraniGrad;
  bool ucitavanjeGradova = true;

  List<CountryDesktopModel> drzave = [];
  CountryDesktopModel? odabranaDrzava;
  bool ucitavanjeDrzava = true;

  final _existingCtrl = ScrollController();
  final _newCtrl = ScrollController();

  static const double _tileSize = 130.0;
  static const double _tileGap = 10.0;

  int get _totalImages => _postojeceSlike.length + _noveSlike.length;

  @override
  void initState() {
    super.initState();

    nazivController = TextEditingController(text: widget.nekretnina['naziv'] ?? '');
    cijenaController = TextEditingController(
      text: (widget.nekretnina['cijena'] ?? '').toString().replaceAll(' KM', ''),
    );
    adresaController = TextEditingController(text: widget.nekretnina['adresa'] ?? '');
    opisController = TextEditingController(text: widget.nekretnina['opis'] ?? '');
    sobeController = TextEditingController(text: (widget.nekretnina['sobe'] ?? '').toString());
    kvadraturaController =
        TextEditingController(text: (widget.nekretnina['kvadratura'] ?? '').toString());

    final raw = (widget.nekretnina['slike'] as List?) ?? [];
    for (final e in raw) {
      if (e is Map) {
        final url = e['url']?.toString() ?? '';
        final id = e['id'];
        _postojeceSlike.add(_ExistingImage(
          url: url,
          id: id is int ? id : (id is String ? int.tryParse(id) : null),
        ));
      } else if (e is String) {
        _postojeceSlike.add(_ExistingImage(url: e, id: null));
      }
    }

    _ucitajGradove();
    _ucitajDrzave();
  }

  @override
  void dispose() {
    nazivController.dispose();
    cijenaController.dispose();
    adresaController.dispose();
    opisController.dispose();
    sobeController.dispose();
    kvadraturaController.dispose();
    _existingCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  Future<void> _ucitajGradove() async {
    try {
      gradovi = await CityService().fetchGradove();
      final current = (widget.nekretnina['grad'] ?? '').toString().toLowerCase();
      odabraniGrad = gradovi.firstWhere(
        (c) => c.name.toLowerCase() == current,
        orElse: () => gradovi.isNotEmpty ? gradovi.first : CityDesktopModel(cityID: 0, name: ''),
      );
    } finally {
      if (mounted) setState(() => ucitavanjeGradova = false);
    }
  }

  Future<void> _ucitajDrzave() async {
    try {
      drzave = await CountryService().fetchCountries();
      final current = (widget.nekretnina['drzava'] ?? '').toString().toLowerCase();
      odabranaDrzava = drzave.firstWhere(
        (d) => d.name.toLowerCase() == current,
        orElse: () => drzave.isNotEmpty ? drzave.first : CountryDesktopModel(countryID: 0, name: ''),
      );
    } finally {
      if (mounted) setState(() => ucitavanjeDrzava = false);
    }
  }

  Future<void> _odaberiNoveSlike() async {
    final remaining = _maxTotalImages - _totalImages;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosegnut maksimalan broj slika ($_maxTotalImages). Uklonite neku da biste dodali novu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;

    final dodaj = picked.take(remaining).map((x) => File(x.path)).toList();

    setState(() {
      _noveSlike.addAll(dodaj);
    });

    if (picked.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dodano ${dodaj.length} od ${picked.length} odabranih (maks. $_maxTotalImages ukupno).'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 50));
    if (_newCtrl.hasClients) {
      _newCtrl.animateTo(
        _newCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _spremi() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await _secureStorage.read(key: 'token') ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Niste prijavljeni'), backgroundColor: Colors.red),
      );
      return;
    }

    final opisRaw = opisController.text.trim();
    final opisSafe = opisRaw.length <= 1000 ? opisRaw : opisRaw.substring(0, 1000);

    final ok = await _service.updateProperty(
      propertyId: widget.nekretnina['id'] as int,
      fields: {
        'Title': nazivController.text.trim(),
        'Description': opisSafe,
        'Price': cijenaController.text.trim(),
        'City': odabraniGrad?.name ?? '',
        'Country': odabranaDrzava?.name ?? '',
        'Address': adresaController.text.trim(),
        'RoomCount': sobeController.text.trim(),
        'Area': kvadraturaController.text.trim(),
      },
      newImages: _noveSlike,
      deleteImageIds: _deletedImageIds,
      token: token,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nekretnina uspješno ažurirana'), backgroundColor: Colors.green),
      );
      widget.onUpdated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška prilikom ažuriranja'), backgroundColor: Colors.red),
      );
    }
  }

  void _scrollBy(ScrollController c, double delta) {
    if (!c.hasClients) return;
    final double target = math.max(0.0, math.min(c.offset + delta, c.position.maxScrollExtent));
    c.animateTo(target, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  void _removeExistingAt(int index) {
    if (index < 0 || index >= _postojeceSlike.length) return;
    final removed = _postojeceSlike.removeAt(index);
    if (removed.id != null) _deletedImageIds.add(removed.id!);
    setState(() {});
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Slika uklonjena (bit će obrisana nakon spremanja).'),
        action: SnackBarAction(
          label: 'Vrati',
          onPressed: () {
            setState(() {
              _postojeceSlike.insert(index.clamp(0, _postojeceSlike.length), removed);
              if (removed.id != null) _deletedImageIds.remove(removed.id);
            });
          },
        ),
      ),
    );
  }

  Widget _buildScroller({
    required List<Widget> tiles,
    required ScrollController controller,
    required double availableWidth,
    required Color arrowColor,
  }) {
    final int visible = math.max(1, (availableWidth / (_tileSize + _tileGap)).floor());
    final bool showArrows = tiles.length > visible;

    return SizedBox(
      height: _tileSize + 10,
      width: double.infinity,
      child: Stack(
        children: [
          Scrollbar(
            controller: controller,
            thumbVisibility: showArrows,
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: Row(children: tiles),
            ),
          ),
          if (showArrows)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: _ScrollButton(
                right: false,
                color: arrowColor,
                onTap: () => _scrollBy(controller, -(_tileSize * 2)),
              ),
            ),
          if (showArrows)
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: _ScrollButton(
                right: true,
                color: arrowColor,
                onTap: () => _scrollBy(controller, _tileSize * 2),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bool hasExisting = _postojeceSlike.isNotEmpty;
    final bool canAddMore = _totalImages < _maxTotalImages;

    return SizedBox(
      width: 760,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Uredi nekretninu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                TextFormField(
                  controller: nazivController,
                  decoration: const InputDecoration(labelText: 'Naziv'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite naziv' : null,
                ),
                TextFormField(
                  controller: cijenaController,
                  decoration: const InputDecoration(labelText: 'Cijena (KM)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite cijenu';
                    return double.tryParse(v.replaceAll(',', '.')) == null ? 'Neispravan broj' : null;
                  },
                ),

                ucitavanjeGradova
                    ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())
                    : DropdownButtonFormField<CityDesktopModel>(
                        decoration: const InputDecoration(labelText: 'Grad'),
                        initialValue: odabraniGrad,
                        items: gradovi.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                        onChanged: (v) => setState(() => odabraniGrad = v),
                        validator: (v) => v == null ? 'Odaberite grad' : null,
                      ),

                ucitavanjeDrzava
                    ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())
                    : DropdownButtonFormField<CountryDesktopModel>(
                        decoration: const InputDecoration(labelText: 'Država'),
                        initialValue: odabranaDrzava,
                        items: drzave.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                        onChanged: (v) => setState(() => odabranaDrzava = v),
                        validator: (v) => v == null ? 'Odaberite državu' : null,
                      ),

                TextFormField(
                  controller: adresaController,
                  decoration: const InputDecoration(labelText: 'Adresa'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite adresu' : null,
                ),

                TextFormField(
                  controller: opisController,
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 4,
                  maxLines: 10,                  
                  maxLength: 1000,                
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1000),
                  ],
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Unesite opis';
                    if (t.length > 1000) return 'Maksimalno 1000 karaktera';
                    return null;
                  },
                ),

                TextFormField(
                  controller: sobeController,
                  decoration: const InputDecoration(labelText: 'Broj soba'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite broj soba';
                    return int.tryParse(v) == null ? 'Neispravan broj' : null;
                  },
                ),
                TextFormField(
                  controller: kvadraturaController,
                  decoration: const InputDecoration(labelText: 'Kvadratura (m²)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite kvadraturu';
                    return double.tryParse(v.replaceAll(',', '.')) == null ? 'Neispravan broj' : null;
                  },
                ),

                const SizedBox(height: 18),

                if (hasExisting) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Postojeće slike', style: Theme.of(context).textTheme.titleMedium),
                      Text('${_totalImages}/$_maxTotalImages', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tiles = List.generate(_postojeceSlike.length, (i) {
                        final img = _postojeceSlike[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: _tileGap),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  img.url,
                                  width: _tileSize,
                                  height: _tileSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: _tileSize,
                                    height: _tileSize,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: _CircleIconButton(
                                  icon: Icons.close,
                                  onTap: () => _removeExistingAt(i),
                                  bgColor: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      });

                      return _buildScroller(
                        tiles: tiles,
                        controller: _existingCtrl,
                        availableWidth: constraints.maxWidth,
                        arrowColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nove slike', style: Theme.of(context).textTheme.titleMedium),
                    Text('${_totalImages}/$_maxTotalImages', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (_noveSlike.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Još niste odabrali nove slike'),
                        ),
                      );
                    }

                    final tiles = List.generate(_noveSlike.length, (i) {
                      final f = _noveSlike[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: _tileGap),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                f,
                                width: _tileSize,
                                height: _tileSize,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: _CircleIconButton(
                                icon: Icons.close,
                                onTap: () => setState(() => _noveSlike.removeAt(i)),
                                bgColor: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    });

                    return _buildScroller(
                      tiles: tiles,
                      controller: _newCtrl,
                      availableWidth: constraints.maxWidth,
                      arrowColor: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: canAddMore ? _odaberiNoveSlike : null,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Odaberi slike'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: _spremi,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 2,
                    ),
                    child: const Text('Spremi izmjene'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExistingImage {
  final String url;
  final int? id;
  _ExistingImage({required this.url, this.id});
}

class _ScrollButton extends StatelessWidget {
  final bool right;
  final VoidCallback onTap;
  final Color color;
  const _ScrollButton({required this.right, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: color.withOpacity(0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(right ? Icons.chevron_right : Icons.chevron_left, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  const _CircleIconButton({required this.icon, required this.onTap, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
