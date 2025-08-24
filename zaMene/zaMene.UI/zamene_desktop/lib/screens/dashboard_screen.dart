import 'dart:io';
import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
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

  bool _isExporting = false;

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

  Future<void> _exportAsPDF() async {
    setState(() => _isExporting = true);
    try {
      final pdf = pw.Document();

      final fontData = await rootBundle.load('assets/NotoSans-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final brojStanova = brojStanovaPoGradu();
      final prosjekOcjena = prosjekOcjenaPoGradu();

      pdf.addPage(
        pw.MultiPage(
          build: (context) {
            final content = <pw.Widget>[
              pw.Text(
                'Izvještaj o statistici stanova',
                style: pw.TextStyle(font: ttf, fontSize: 22),
              ),
              pw.SizedBox(height: 20),
            ];

            final ns = najskupljiStan();        
            final nr = najviseRezervacijaText();  
            final tp = topPonude();              

            if (ns != null) {
              content.add(pw.Text('Najskuplji stan: $ns', style: pw.TextStyle(font: ttf)));
            }

            content.add(pw.Text('Najviše rezervacija: $nr', style: pw.TextStyle(font: ttf)));

            if (tp != null) {
              content.add(pw.Text('Top ponude: $tp', style: pw.TextStyle(font: ttf)));
            }

            content.add(pw.SizedBox(height: 20));

            if (brojStanova.isNotEmpty) {
              content.add(pw.Text(
                'Broj stanova po gradu:',
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
              ));
              content.addAll(brojStanova.entries.map(
                (e) => pw.Text('${e.key}: ${e.value.toStringAsFixed(0)}',
                    style: pw.TextStyle(font: ttf)),
              ));
              content.add(pw.SizedBox(height: 20));
            }

            if (prosjekOcjena.isNotEmpty) {
              content.add(pw.Text(
                'Prosječna ocjena po gradu:',
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
              ));
              content.addAll(prosjekOcjena.entries.map(
                (e) => pw.Text('${e.key}: ${e.value.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: ttf)),
              ));
            }

            return content;
          },
        ),
      );

      final bytes = await pdf.save();

      final suggested =
          'Dashboard_izvjestaj_${DateTime.now().toIso8601String().split('T').first}.pdf';
      final path = await getSavePath(
        suggestedName: suggested,
        acceptedTypeGroups: [
          const XTypeGroup(label: 'PDF', extensions: ['pdf'])
        ],
      );

      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export otkazan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      var finalPath = path;
      if (!finalPath.toLowerCase().endsWith('.pdf')) {
        finalPath = '$finalPath.pdf';
      }

      final file = File(finalPath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF spremljen: $finalPath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri exportu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
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
              onPressed: _isExporting ? null : _exportAsPDF,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isExporting ? "Exportujem..." : "Exportuj izvještaj"),
            ),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildInfoCard(Icons.monetization_on, "Najskuplji stan", najskupljiStan()),
              _buildInfoCard(Icons.star, "Top ponuda", topPonude()),
              _buildInfoCardAlways(Icons.hotel, "Najviše rezervacija", najviseRezervacijaText()),
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

  Widget _buildInfoCard(IconData icon, String title, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return _infoCardBase(icon, title, value);
  }

  Widget _buildInfoCardAlways(IconData icon, String title, String value) {
    return _infoCardBase(icon, title, value);
  }

  Widget _infoCardBase(IconData icon, String title, String value) {
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
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
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
    if (data.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("Nema podataka"),
      );
    }

    final entries = data.entries.toList();
    final interval = _suggestInterval(data);

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final i = group.x.toInt();
                final city = (i >= 0 && i < entries.length) ? entries[i].key : '';
                final value = rod.toY;
                return BarTooltipItem(
                  '$city\n${value.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          barGroups: entries.asMap().entries.map((e) {
            final index = e.key;
            final y = e.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: y,
                  color: Colors.blue,
                  width: 20,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  final label = (value % 1 == 0)
                      ? value.toInt().toString()
                      : value.toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.left,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < entries.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 6,
                      child: Text(
                        entries[i].key,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
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

  double _suggestInterval(Map<String, double> data) {
    if (data.isEmpty) return 1;
    final maxY = data.values.fold<double>(0, (p, c) => math.max(p, c));
    if (maxY <= 5) return 1;       
    if (maxY <= 10) return 2;
    if (maxY <= 25) return 5;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    return (maxY / 5).ceilToDouble();
  }

  Map<String, double> brojStanovaPoGradu() {
    final Map<String, int> counts = {};
    for (var s in stats) {
      counts[s.city] = (counts[s.city] ?? 0) + 1;
    }
    return counts.map((k, v) => MapEntry(k, v.toDouble()));
  }

  String? najskupljiStan() {
    if (stats.isEmpty) return null;
    final naj = stats.reduce((a, b) => a.viewCount > b.viewCount ? a : b);
    if (naj.viewCount <= 0) return null;
    return "${naj.title} (${naj.viewCount} pregleda)";
  }

  String najviseRezervacijaText() {
    if (stats.isEmpty) return "0";
    final naj = stats.reduce((a, b) => a.totalReservation > b.totalReservation ? a : b);
    if (naj.totalReservation <= 0) return "0";
    final suf = "rezervacija";
    return "${naj.title} (${naj.totalReservation} $suf)";
  }

  String? topPonude() {
    final top = stats.where((s) => s.isTopProperty).map((e) => e.title).toList();
    if (top.isEmpty) return null;
    return top.join(", ");
  }

  Map<String, double> prosjekOcjenaPoGradu() {
    final Map<String, List<double>> gradOcjene = {};
    for (var s in stats) {
      gradOcjene.putIfAbsent(s.city, () => []).add(s.averageRating);
    }
    return gradOcjene.map((grad, ocjene) {
      final avg = ocjene.reduce((a, b) => a + b) / ocjene.length;
      return MapEntry(grad, avg);
    });
  }
}
