import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zamene_mobile/models/my_reservations_model.dart';
import 'package:zamene_mobile/models/property_model.dart';
import 'package:zamene_mobile/screens/property_detail_screen.dart';
import 'package:zamene_mobile/services/reservation_service.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late Future<List<MyReservations>> futureReservations;
  Timer? _statusTicker;

  @override
  void initState() {
    super.initState();
    futureReservations = ReservationService.getMyReservations();
    _statusTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    const Color whiteColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje rezervacije'),
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder<List<MyReservations>>(
        future: futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Greška: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Nemate rezervacija.',
                style: TextStyle(color: primaryColor, fontSize: 18),
              ),
            );
          }

          final reservations = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = reservations[index];

              final computed = _computedStatus(r);
              final pretty = _prettyStatus(computed);

              return Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    List<String> _asStringList(dynamic v) {
                      if (v == null) return <String>[];
                      if (v is List<String>) return v;
                      if (v is List) {
                        return v
                            .map((e) => e?.toString() ?? '')
                            .where((s) => s.trim().isNotEmpty)
                            .toList();
                      }
                      return <String>[];
                    }

                    final prop = PropertyModel(
                      propertyID: r.propertyID,
                      title: r.propertyTitle,
                      description: r.propertyDescription,
                      price: r.propertyPrice,
                      city: r.propertyCity,
                      address: null,
                      averageRating: null,
                      agentFullName: r.propertyAgentName,
                      agentPhoneNumber: r.propertyAgentPhone,
                      agentProfileImageUrl: null,
                      imageUrls: _asStringList(r.propertyImageUrls),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(property: prop),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.propertyTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              r.propertyCity,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 18, color: Color.fromARGB(255, 179, 165, 165)),
                            const SizedBox(width: 6),
                            Text(
                              '${r.startDate.toLocal().toString().split(" ")[0]} - ${r.endDate.toLocal().toString().split(" ")[0]}',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(computed),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                pretty,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "${r.propertyPrice.toStringAsFixed(2)} BAM",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _computedStatus(MyReservations r) {
    final now = DateTime.now();
    final end = r.endDate.toLocal();
    final s = r.status.toLowerCase().trim();

    final isActive = s == 'aktivno' || s == 'active' || s == 'aktivan' || s == 'aktivna';

    if (isActive && !end.isAfter(now)) {
      return 'zavrseno';
    }
    if (s == 'završeno') return 'zavrseno';
    return s;
  }

  String _prettyStatus(String s) {
    switch (s.toLowerCase().trim()) {
      case 'aktivno':
      case 'active':
      case 'aktivan':
      case 'aktivna':
        return 'Aktivno';
      case 'otkazano':
      case 'cancelled':
        return 'Otkazano';
      case 'zavrseno':
      case 'završeno':
      case 'finished':
        return 'Završeno';
      default:
        return s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'aktivno':
      case 'active':
      case 'aktivan':
      case 'aktivna':
        return Colors.green.shade600;
      case 'otkazano':
      case 'cancelled':
        return Colors.red.shade600;
      case 'zavrseno':
      case 'završeno':
      case 'finished':
        return Colors.grey.shade600;
      default:
        return Colors.blue.shade400;
    }
  }
}
