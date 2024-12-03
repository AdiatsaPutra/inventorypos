import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class POSOverviewPage extends StatefulWidget {
  const POSOverviewPage({super.key});

  @override
  _POSOverviewPageState createState() => _POSOverviewPageState();
}

class _POSOverviewPageState extends State<POSOverviewPage> {
  final List<Map<String, dynamic>> _transactions = [
    {'product': 'Laptop', 'quantity': 3, 'price': 800.0, 'day': 1},
    {'product': 'Mouse', 'quantity': 5, 'price': 20.0, 'day': 1},
    {'product': 'Keyboard', 'quantity': 2, 'price': 50.0, 'day': 2},
    {'product': 'Laptop', 'quantity': 1, 'price': 800.0, 'day': 3},
    {'product': 'Mouse', 'quantity': 7, 'price': 20.0, 'day': 3},
  ];

  double get totalRevenue {
    return _transactions.fold(0.0, (sum, transaction) {
      return sum + (transaction['quantity'] * transaction['price']);
    });
  }

  int get totalItemsSold {
    return _transactions.fold(0, (sum, transaction) {
      return (sum + transaction['quantity']).toInt();
    });
  }

  String get mostSoldItem {
    var productCount = <String, int>{};

    for (var transaction in _transactions) {
      productCount.update(
        transaction['product'],
        (value) => (value + transaction['quantity']).toInt(),
        ifAbsent: () => transaction['quantity'],
      );
    }

    var mostSold =
        productCount.entries.reduce((a, b) => a.value > b.value ? a : b);

    return mostSold.key;
  }

  List<_ChartData> get dailyChartData {
    var dailyRevenue = List<double>.filled(7, 0.0);

    for (var transaction in _transactions) {
      dailyRevenue[transaction['day'] - 1] +=
          transaction['quantity'] * transaction['price'];
    }

    return List.generate(
      7,
      (index) => _ChartData('Hari ${index + 1}', dailyRevenue[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistik Section
              Row(
                children: [
                  Expanded(
                      child: _buildStatisticCard('Total Pendapatan',
                          'Rp${totalRevenue.toStringAsFixed(2)}')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildStatisticCard(
                          'Barang Terjual', '$totalItemsSold')),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatisticCard('Barang Terlaris', mostSoldItem),
              const SizedBox(height: 16),

              // Chart Section
              Text(
                'Pendapatan Harian',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Pendapatan (Rp)'),
                      ),
                      series: <CartesianSeries<dynamic, dynamic>>[
                        ColumnSeries<dynamic, dynamic>(
                          dataSource: dailyChartData,
                          xValueMapper: (dynamic data, _) => data.day,
                          yValueMapper: (dynamic data, _) => data.revenue,
                          color: Colors.blueAccent,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.day, this.revenue);
  final String day;
  final double revenue;
}
