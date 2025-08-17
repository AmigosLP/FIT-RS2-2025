import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:zamene_desktop/models/property_statistics_model.dart';
import 'package:zamene_desktop/providers/property_statistics_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PropertyStatisticsService _service = PropertyStatisticsService();
  List<PropertyStatisticsModel> stats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final result = await _service.fetchStatistics();
      setState(() {
        stats = result;
        isLoading = false;
      });
    } catch (e) {
      print("Greška: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

 void _exportAsPDF() async {
  final pdf = pw.Document();

  final fontData = await rootBundle.load('assets/NotoSans-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  final brojStanova = brojStanovaPoGradu();
  final prosjekOcjena = prosjekOcjenaPoGradu();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Izvještaj o statistici stanova', style: pw.TextStyle(font: ttf, fontSize: 22)),
        pw.SizedBox(height: 20),
        pw.Text('Najskuplji stan: ${najskupljiStan()}', style: pw.TextStyle(font: ttf)),
        pw.Text('Najviše rezervacija: ${najviseRezervacija()}', style: pw.TextStyle(font: ttf)),
        pw.Text('Top ponude: ${topPonude()}', style: pw.TextStyle(font: ttf)),
        pw.SizedBox(height: 20),
        pw.Text('Broj stanova po gradu:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
        pw.Column(
          children: brojStanova.entries.map((e) =>
            pw.Text('${e.key}: ${e.value.toStringAsFixed(0)}', style: pw.TextStyle(font: ttf))).toList()
        ),
        pw.SizedBox(height: 20),
        pw.Text('Prosječna ocjena po gradu:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
        pw.Column(
          children: prosjekOcjena.entries.map((e) =>
            pw.Text('${e.key}: ${e.value.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf))).toList()
        ),
      ],
    ),
  );

  final file = File('izvjestaj.pdf');
  await file.writeAsBytes(await pdf.save());

  print("PDF uspješno spremljen: ${file.path}");
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "Administracija statistike",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Text(
            "Dashboard i statistika stanova",
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _exportAsPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Exportuj izvještaj"),
            ),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildInfoCard(Icons.monetization_on, "Najskuplji stan", najskupljiStan()),
              _buildInfoCard(Icons.star, "Top ponuda", topPonude()),
              _buildInfoCard(Icons.hotel, "Najviše rezervacija", najviseRezervacija()),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Broj stanova po gradu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildChart("Broj stanova po gradu", brojStanovaPoGradu()),
          const SizedBox(height: 30),
          const Text(
            "Prosječna ocjena po gradu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildChart("Prosječna ocjena po gradu", prosjekOcjenaPoGradu()),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(value,
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(String title, Map<String, double> data) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: data.entries.toList().asMap().entries.map((entry) {
            int index = entry.key;
            double value = entry.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(toY: value, color: Colors.blue, width: 20),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 6,
                      child: Text(
                        data.keys.elementAt(index),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Map<String, double> brojStanovaPoGradu() {
    Map<String, int> counts = {};
    for (var s in stats) {
      counts[s.city] = (counts[s.city] ?? 0) + 1;
    }
    return counts.map((k, v) => MapEntry(k, v.toDouble()));
  }

  String najskupljiStan() {
    if (stats.isEmpty) return "Nema podataka";
    final najskuplji = stats.reduce((a, b) => a.viewCount > b.viewCount ? a : b);
    return "${najskuplji.title} (${najskuplji.viewCount} pregleda)";
  }

  String najviseRezervacija() {
    if (stats.isEmpty) return "Nema podataka";
    final najvise = stats.reduce((a, b) => a.totalReservation > b.totalReservation ? a : b);
    return "${najvise.title} (${najvise.totalReservation} rezervacija)";
  }

  String topPonude() {
    final top = stats.where((s) => s.isTopProperty).map((e) => e.title).toList();
    return top.isEmpty ? "Nema top ponuda" : top.join(", ");
  }

  Map<String, double> prosjekOcjenaPoGradu() {
    Map<String, List<double>> gradOcjene = {};
    for (var s in stats) {
      gradOcjene.putIfAbsent(s.city, () => []).add(s.averageRating);
    }
    return gradOcjene.map((grad, ocjene) {
      final avg = ocjene.reduce((a, b) => a + b) / ocjene.length;
      return MapEntry(grad, avg);
    });
  }
}
