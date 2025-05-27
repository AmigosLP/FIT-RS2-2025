import 'package:flutter/material.dart';
import 'package:zamene_mobile/models/property_model.dart';
import 'package:zamene_mobile/screens/property_detail_screen.dart';
import 'package:zamene_mobile/services/property_service.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String aktivnaKategorija = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;
  String filterTekst = '';
  String selektovaniGrad = 'Sarajevo';

  late Future<List<PropertyModel>> nekretnineFuture;

  Future<void> loadPropertiesWithRatings() async {
  final properties = await PropertyService().getAllProperties();
  
  for (var property in properties) {
    property.averageRating = await PropertyService().getAveragePropertyRating(property.propertyID);
  }

  setState(() {
    nekretnineFuture = Future.value(properties);
  });
}


  @override
  void initState() {
    super.initState();
    AuthProvider.username = "string";
    AuthProvider.password = "string";
    nekretnineFuture = Future.value([]);
    loadPropertiesWithRatings();
  }

  final List<String> gradovi = [
    'Sarajevo',
    'Mostar',
    'Tuzla',
    'Zenica',
    'Banja Luka',
    'Trebinje',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            _scrollController.animateTo(
              250,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
            FocusScope.of(context).requestFocus(_searchFocusNode);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.blue,
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
                        items: gradovi
                            .map((value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/user.png"),
                    radius: 20,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Dobrodošao, ${AuthProvider.displayName ?? 'Korisniče'}!",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
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
                  suffixIcon: filterTekst.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              filterTekst = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['All', 'Kuće', 'Apartmani', 'Sobe']
                    .map((kategorija) => GestureDetector(
                          onTap: () {
                            setState(() {
                              aktivnaKategorija = kategorija;
                            });
                          },
                          child: Chip(
                            label: Text(
                              kategorija,
                              style: TextStyle(
                                color: aktivnaKategorija == kategorija
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            backgroundColor: aktivnaKategorija == kategorija
                                ? Colors.blue
                                : Colors.grey[200],
                          ),
                        ))
                    .toList(),
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

                  final properties = snapshot.data!
                      .where((p) =>
                          (p.city == selektovaniGrad) &&
                          (aktivnaKategorija == 'All') &&
                          (p.title.toLowerCase().contains(filterTekst.toLowerCase())))
                      .toList();

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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildCard(PropertyModel p) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyDetailScreen(
            nekretnina: {
              'propertyID': p.propertyID,
              'naziv': p.title,
              'cijena': "${p.price} BAM",
              'adresa': p.address.toString(),
              'ocjena': p.averageRating.toString(),
              'slika': p.imageUrls != null && p.imageUrls!.isNotEmpty ? p.imageUrls!.first : 'assets/images/default.png',
              'imagesUrls': p.imageUrls
            },
          ),
        ),
      );
    },
    child: Container(
      width: 180,
      height: 100, // ukupna visina kartice
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Slika zauzima pola visine kartice (150)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: p.imageUrls != null && p.imageUrls!.isNotEmpty 
              ? Image.network(
                p.imageUrls!.first,
                fit: BoxFit.cover,
              ) : Image.asset(
                'assets/images/placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 12), // malo prostora ispod slike

          // Naslov i grad su u zasebnoj koloni da budu složeni
          Text(
            p.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            p.city,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(), // gura donji red s cijenom i ocjenom na dno

          Row(
            children: [
              Text(
                "${p.price} BAM",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(Icons.star, size: 16, color: Colors.amber),
              Text(
                (p.averageRating ?? 0.0).toStringAsFixed(1),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
