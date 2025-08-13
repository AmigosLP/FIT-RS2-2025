import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zamene_mobile/models/property_model.dart';
import 'package:zamene_mobile/providers/favorite_provider.dart';
import 'package:zamene_mobile/screens/property_detail_screen.dart';
import 'package:zamene_mobile/services/property_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Ako backend vraća relativne URL-ove
  static const String backendBaseUrl = 'http://10.0.2.2:5283';

  String resolveImage(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : ('$backendBaseUrl$path');
  }

  late Future<List<PropertyModel>> _future;

  Future<List<PropertyModel>> _loadFavoriteProperties(Set<int> favoriteIds) async {
    // Ako već imaš endpoint /Favorite/mine koji vraća kompletne nekretnine,
    // možeš ovdje pozvati taj endpoint umjesto filtriranja svih.
    final all = await PropertyService().getAllProperties();
    return all.where((p) => p.propertyID != null && favoriteIds.contains(p.propertyID!)).toList();
  }

  @override
  void initState() {
    super.initState();
    final favIds = context.read<FavoriteProvider>().ids;
    _future = _loadFavoriteProperties(favIds);
  }

  Future<void> _refresh() async {
    final favIds = context.read<FavoriteProvider>().ids;
    final data = await _loadFavoriteProperties(favIds);
    if (!mounted) return;
    setState(() {
      _future = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriti'),
        centerTitle: true,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProv, _) {
          // Resync prikaza kada se promijene favoriti
          _future = _loadFavoriteProperties(favProv.ids);

          return FutureBuilder<List<PropertyModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Greška: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Nemate sačuvanih favorita.\nDodajte nekretninu u favorite dodirom na srce.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,          // dvije u redu
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 180 / 230, // približno kao na home-u
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    final img = (p.imageUrls?.isNotEmpty ?? false)
                        ? resolveImage(p.imageUrls!.first)
                        : '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(nekretnina: p.toJson()),
                          ),
                        );
                      },
                      child: Container(
                        // ISTI DIZAJN KARTICE KAO NA HOME SCREEN-U
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Slika + srce (isto kao Home)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    height: 100,
                                    width: double.infinity,
                                    child: img.isNotEmpty
                                        ? Image.network(
                                            img,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Image.asset('assets/images/zaMeneLogo2.png', fit: BoxFit.cover),
                                          )
                                        : Image.asset('assets/images/zaMeneLogo2.png', fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Material(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () async {
                                          if (p.propertyID == null) return;
                                          final wasFav = favProv.isFavorite(p.propertyID!);
                                          try {
                                            await favProv.toggle(p.propertyID!);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    wasFav
                                                        ? 'Uklonjeno iz favorita'
                                                        : 'Dodano u favorite',
                                                  ),
                                                  backgroundColor:
                                                      wasFav ? Colors.red : Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text('Greška: $e'),
                                                  backgroundColor: Colors.red,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                          }
                                        },
                                        child: Center(
                                          child: Icon(
                                            favProv.isFavorite(p.propertyID ?? -1)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 18, // ista manja veličina kao na home-u
                                            color: favProv.isFavorite(p.propertyID ?? -1)
                                                ? Colors.red
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p.title ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.city ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  "${(p.price ?? 0).toStringAsFixed(2)} BAM",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                Text(
                                  (p.averageRating ?? 0.0).toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
