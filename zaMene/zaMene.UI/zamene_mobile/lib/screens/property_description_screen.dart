import 'package:flutter/material.dart';
import 'package:zamene_mobile/models/property_model.dart';

class PropertyDescriptionScreen extends StatelessWidget {
  final PropertyModel property;

  const PropertyDescriptionScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property.title ?? ''),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.imageUrls != null && property.imageUrls!.isNotEmpty)
              Center(
                child: SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: property.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            property.imageUrls![index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Center(
                child: Image.asset(
                  'assets/images/placeholder.jpg',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                property.title ?? '',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    property.address ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  property.city ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '${(property.price ?? 0).toStringAsFixed(2)} KM',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            if (property.averageRating != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '${property.averageRating!.toStringAsFixed(1)} / 5',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: (property.agentProfileImageUrl != null &&
                          property.agentProfileImageUrl!.isNotEmpty)
                      ? NetworkImage(property.agentProfileImageUrl!)
                      : const AssetImage('assets/images/user.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    property.agentFullName ?? 'Nepoznat vlasnik',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Opis nekretnine',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: property.description ?? '',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}