import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  _StatisticsScreen createState() => _StatisticsScreen();
}

class _StatisticsScreen extends State<StatisticsScreen> {
  final List<Map<String, dynamic>> nekretnine = [
    {
      'naziv': 'Stan Mostar Centar',
      'cijena': 800,
      'grad': 'Mostar',
      'ocjene': [4, 5, 5]
    },
    {
      'naziv': 'Apartman Sarajevo',
      'cijena': 1200,
      'grad': 'Sarajevo',
      'ocjene': [3, 4]
    },
    {
      'naziv': 'Garsonjera Banja Luka',
      'cijena': 500,
      'grad': 'Banja Luka',
      'ocjene': [5]
    },
    {
      'naziv': 'Studio Tuzla',
      'cijena': 400,
      'grad': 'Tuzla',
      'ocjene': [2, 3, 4]
    },
    {
      'naziv': 'Vila Trebinje',
      'cijena': 2000,
      'grad': 'Trebinje',
      'ocjene': [4, 5]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final brojPoGradu = _brojStanovaPoGradu();
    final najskuplji = _najskupljiStan();
    final najjeftiniji = _najjefitnijiStan();
    final prosjekOcjena = _prosjekOcjenaPoGradu();

    return Scaffold(
      appBar: AppBar(title: Text("Statistika")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChart("Broj stanova po gradu", brojPoGradu),
            SizedBox(height: 20),
            _buildInfoCard("Najskuplji stan", "${najskuplji['naziv']} - ${najskuplji['cijena']} KM"),
            _buildInfoCard("Najjeftiniji stan", "${najjeftiniji['naziv']} - ${najjeftiniji['cijena']} KM"),
            SizedBox(height: 20),
            _buildChart("Prosječna ocjena po gradu", prosjekOcjena),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildChart(String title, Map<String, double> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: data.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                    int index = entry.key;
                    String label = entry.value.key;
                    double value = entry.value.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(toY: value, color: Colors.blue, width: 20),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  })
                  .toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index < data.length) {
                        String label = data.keys.elementAt(index);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(label, style: TextStyle(fontSize: 10)),
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
        ),
      ],
    );
  }

  Map<String, double> _brojStanovaPoGradu() {
    Map<String, int> counts = {};
    for (var n in nekretnine) {
      counts[n['grad']] = (counts[n['grad']] ?? 0) + 1;
    }
    return counts.map((k, v) => MapEntry(k, v.toDouble()));
  }

  Map<String, dynamic> _najskupljiStan() {
    return nekretnine.reduce((a, b) => a['cijena'] > b['cijena'] ? a : b);
  }

  Map<String, dynamic> _najjefitnijiStan() {
    return nekretnine.reduce((a, b) => a['cijena'] < b['cijena'] ? a : b);
  }

  Map<String, double> _prosjekOcjenaPoGradu() {
    Map<String, List<int>> gradOcjene = {};

    for (var n in nekretnine) {
      gradOcjene.putIfAbsent(n['grad'], () => []).addAll(n['ocjene']);
    }

    return gradOcjene.map((grad, ocjene) {
      final avg = ocjene.reduce((a, b) => a + b) / ocjene.length;
      return MapEntry(grad, avg);
    });
  }
}
