import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zamene_mobile/models/reservation_model.dart';
import 'package:zamene_mobile/models/reservation_paypal_model.dart';
import 'package:zamene_mobile/screens/paypal_payment.dart';
import 'package:zamene_mobile/services/reservation_service.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> nekretnina;

  const PaymentScreen({super.key, required this.nekretnina});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  List<ReservationModel> zauzetiTermini = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final service = ReservationService();
      zauzetiTermini = await service.getActiveReservations(widget.nekretnina['propertyID']);
    } catch (e) {
      print("Greška pri dohvaćanju rezervacija: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _selectDate({required bool isCheckIn}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (isZauzet(picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Odabrani datum je zauzet. Odaberite drugi.")),
        );
        setState(() {
          if (isCheckIn) checkInDate = null;
          else checkOutDate = null;
        });
        return;
      }

      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  bool isZauzet(DateTime day) {
    for (var rezervacija in zauzetiTermini) {
      if (isSameDay(day, rezervacija.startDate) ||
          (day.isAfter(rezervacija.startDate) && day.isBefore(rezervacija.endDate))) {
        return true;
      }
    }
    return false;
  }

  bool _isOdabraniPeriodValidan() {
    if (checkInDate == null || checkOutDate == null) return false;
    if (!checkOutDate!.isAfter(checkInDate!)) return false;

    for (DateTime date = checkInDate!;
        date.isBefore(checkOutDate!);
        date = date.add(const Duration(days: 1))) {
      if (isZauzet(date)) return false;
    }

    return true;
  }

  double _calculateTotalPrice() {
    if (checkInDate == null || checkOutDate == null) return 0.0;
    if (!checkOutDate!.isAfter(checkInDate!)) return 0.0;

    final brojNoci = checkOutDate!.difference(checkInDate!).inDays;
    final cijenaPoNoci = widget.nekretnina['cijena'] as double;

    return brojNoci * cijenaPoNoci;
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Row(
            children: [
              Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.green[300], shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text("Slobodno"),
            ],
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.red[300], shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text("Zauzeto"),
            ],
          ),
        ],
      ),
    );
  }

  void _startPaymentProcess() {
    final ukupno = _calculateTotalPrice();

    try {
      final token = AuthProvider.token;
      if (token == null) throw Exception("Token je null");

      final decodedToken = JwtDecoder.decode(token);
      print("Decoded token: $decodedToken");

      const userIdKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
      final userIdStr = decodedToken[userIdKey];
      if (userIdStr == null) throw Exception("Token ne sadrži userID");

      final userId = int.parse(userIdStr);

      final reservationData = ReservationPaymentModel(
        propertyID: widget.nekretnina['propertyID'],
        userID: userId,
        startDate: checkInDate!,
        endDate: checkOutDate!,
        totalPrice: ukupno.toDouble(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaypalPaymentScreen(reservationData: reservationData),
        ),
      );
    } catch (e) {
      print("Greška pri dekodiranju tokena: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri učitavanju korisnika.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nekretnina = widget.nekretnina;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plaćanje"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNekretninaCard(nekretnina),
                  const SizedBox(height: 20),
                  const Text("Dostupnost", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: DateTime.now(),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) {
                        final bool zauzet = isZauzet(day);
                        return Container(
                          decoration: BoxDecoration(
                            color: zauzet ? Colors.red[300] : Colors.green[300],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                    onDaySelected: (selectedDay, _) {},
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(height: 20),
                  const Text("Period", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(checkInDate != null
                              ? "${checkInDate!.day}.${checkInDate!.month}.${checkInDate!.year}"
                              : "Check In"),
                          onPressed: () => _selectDate(isCheckIn: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(checkOutDate != null
                              ? "${checkOutDate!.day}.${checkOutDate!.month}.${checkOutDate!.year}"
                              : "Check Out"),
                          onPressed: () => _selectDate(isCheckIn: false),
                        ),
                      ),
                    ],
                  ),
                  if (checkInDate != null && checkOutDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ukupno: ${_calculateTotalPrice().toStringAsFixed(2)} KM",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (!_isOdabraniPeriodValidan())
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                "Molimo izaberite validne datume.",
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isOdabraniPeriodValidan() ? _startPaymentProcess : null,
                        icon: const Icon(Icons.payment, color: Colors.white),
                        label: const Text("Plati", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOdabraniPeriodValidan() ? Colors.blue : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNekretninaCard(Map nekretnina) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nekretnina['naziv'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(nekretnina['adresa'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text("${(nekretnina['cijena'] as double).toStringAsFixed(2)} KM", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
