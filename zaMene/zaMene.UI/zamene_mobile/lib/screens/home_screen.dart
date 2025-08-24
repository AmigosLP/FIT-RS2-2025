import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zamene_mobile/models/city_model.dart';
import 'package:zamene_mobile/models/property_model.dart';
import 'package:zamene_mobile/models/homepage_recommendation_model.dart';
import 'package:zamene_mobile/screens/favorite_screen.dart';
import 'package:zamene_mobile/screens/my_reservations.dart';
import 'package:zamene_mobile/screens/notification_screen.dart';
import 'package:zamene_mobile/screens/property_detail_screen.dart';
import 'package:zamene_mobile/services/city_service.dart';
import 'package:zamene_mobile/services/property_service.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/screens/user_profile_screen.dart';
import 'package:zamene_mobile/services/user_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:zamene_mobile/providers/notification_provider.dart';
import 'package:zamene_mobile/providers/favorite_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;
  String filterTekst = '';
  String? selektovaniGrad;
  String? profilePictureUrl;

  late Future<List<PropertyModel>> nekretnineFuture;
  late Future<List<City>> gradoviFuture;
  List<City> gradovi = [];

  HomepageRecommendationModel? homepageRecommendation;
  bool loadingTopPonuda = true;

  int? _extractUserIdFromToken() {
    final token = AuthProvider.token;
    if (token == null || token.isEmpty) return null;
    final decodedToken = JwtDecoder.decode(token);
    final userIdString = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? decodedToken['nameid'];
    if (userIdString == null) return null;
    return int.tryParse(userIdString.toString());
  }

  Future<void> loadPropertiesWithRatings() async {
    final properties = await PropertyService().getAllProperties();
    for (var property in properties) {
      property.averageRating = await PropertyService().getAveragePropertyRating(property.propertyID);
    }
    if (!mounted) return;
    setState(() {
      nekretnineFuture = Future.value(properties);
    });
  }

  Future<void> loadHomepageRecommendations() async {
    try {
      final userId = await UserService().getUserIdFromToken();
      final data = await PropertyService().getHomepageRecommendations(userId);

      if (data.properties.isNotEmpty) {
        for (final p in data.properties) {
          if (p.propertyID != null) {
            p.averageRating = await PropertyService().getAveragePropertyRating(p.propertyID);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        homepageRecommendation = data;
        loadingTopPonuda = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        homepageRecommendation = null;
        loadingTopPonuda = false;
      });
    }
  }

  Future<void> loadProfilnaSlika() async {
    try {
      final profil = await UserService().getUserProfile();
      if (!mounted) return;
      setState(() {
        profilePictureUrl = profil['profileImageUrl'];
      });
    } catch (e) {}
  }

  void _showLogoutDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text('Potvrda odjave', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
        ),
        content: const SizedBox(
          height: 60,
          child: Center(
            child: Text('Da li ste sigurni da želite odjaviti se?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(120, 40)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(120, 40)),
            onPressed: () {
              AuthProvider.token = null;
              AuthProvider.displayName = null;
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Odjavi se'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    gradoviFuture = CityService().getCities();
    gradoviFuture.then((lista) {
      if (!mounted) return;
      setState(() {
        gradovi = lista;
        if (gradovi.isNotEmpty) {
          selektovaniGrad = gradovi[0].name;
        }
      });
    });

    nekretnineFuture = Future.value([]);
    loadPropertiesWithRatings();
    loadHomepageRecommendations();
    loadProfilnaSlika();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount();
      try {
        await Provider.of<FavoriteProvider>(context, listen: false).syncFromServer();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          if (_selectedIndex == index) return;
          if (index == 1) {
            _scrollController.animateTo(250, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            FocusScope.of(context).requestFocus(_searchFocusNode);
          } else if (index == 2) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReservationsScreen()));
          } else if (index == 3) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfileScreen()));
            await loadProfilnaSlika();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.book_online_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: _scrollController,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: selektovaniGrad,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selektovaniGrad = newValue;
                            });
                          }
                        },
                        items: gradovi.map((city) {
                          return DropdownMenuItem<String>(value: city.name, child: Text(city.name));
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        tooltip: 'Favoriti',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                          );
                        },
                      ),
                      Consumer<NotificationProvider>(
                        builder: (context, notificationProvider, _) {
                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                  );
                                  await notificationProvider.fetchUnreadCount();
                                },
                              ),
                              if (notificationProvider.unreadCount > 0)
                                Positioned(
                                  right: 11,
                                  top: 11,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Text(
                                      '${notificationProvider.unreadCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: profilePictureUrl != null ? NetworkImage(profilePictureUrl!) : const AssetImage("assets/images/user.png") as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.blue),
                        tooltip: 'Odjava',
                        onPressed: _showLogoutDialog,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text("Dobrodošao/la, ${AuthProvider.displayName ?? 'Korisniče'}!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
              const Text("#zaMene", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    filterTekst = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pretraži stan za rentanje',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<PropertyModel>>(
                future: nekretnineFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Greška: ${snapshot.error}"));
                  }
                  final properties = snapshot.data!.where((p) {
                    final matchesCity = p.city == selektovaniGrad;
                    final matchesSearch = p.title?.toLowerCase().contains(filterTekst.toLowerCase()) ?? false;
                    return matchesCity && matchesSearch;
                  }).toList();
                  if (properties.isEmpty) {
                    return const Center(child: Text("Nema rezultata."));
                  }
                  return SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final p = properties[index];
                        return _buildCard(p);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text("Top ponuda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 10),
              if (loadingTopPonuda)
                const Center(child: CircularProgressIndicator())
              else if (homepageRecommendation == null || homepageRecommendation!.properties.isEmpty)
                const Text("Nema preporučenih nekretnina.")
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((homepageRecommendation?.message ?? '').isNotEmpty)
                      Text(homepageRecommendation!.message, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: homepageRecommendation!.properties.length,
                        itemBuilder: (context, index) {
                          final p = homepageRecommendation!.properties[index];
                          return _buildCard(p);
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(PropertyModel p) {
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)),
        );

        if (changed == true && mounted) {
          await loadPropertiesWithRatings();     
          await loadHomepageRecommendations();    
          setState(() {});
        }
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: (p.imageUrls?.isNotEmpty ?? false)
                        ? Image.network(p.imageUrls!.first, fit: BoxFit.cover)
                        : Image.asset('assets/images/zaMeneLogo2.png', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProv, _) {
                      final isFav = (p.propertyID != null) && favProv.isFavorite(p.propertyID);
                      return SizedBox(
                        width: 32,
                        height: 32,
                        child: Material(
                          color: Colors.white.withOpacity(0.9),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              final wasFav = isFav;
                              try {
                                await favProv.toggle(p.propertyID);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(wasFav ? 'Uklonjeno iz favorita' : 'Dodano u favorite'),
                                      backgroundColor: wasFav ? Colors.red : Colors.green,
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
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isFav ? Colors.red : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.title ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(p.city ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Text("${p.price} BAM", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text((p.averageRating ?? 0.0).toStringAsFixed(1), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
