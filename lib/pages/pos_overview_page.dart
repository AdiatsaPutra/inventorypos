import 'package:flutter/material.dart';
import 'package:inventorypos/extension/number_extension.dart';
import 'package:inventorypos/provider/dashboard_provider.dart';
import 'package:inventorypos/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class POSOverviewPage extends StatelessWidget {
  const POSOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return CircularProgressIndicator();
                  }

                  final summary = provider.weeklyProductSold?.first ?? {};

                  return Builder(builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatisticCard(
                                context,
                                'Total Pendapatan',
                                provider.totalOfAllTransactions
                                        ?.toInt()
                                        .toRupiah() ??
                                    '0',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatisticCard(
                                context,
                                'Barang Terjual',
                                '${provider.totalProductsSold ?? '0'}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStatisticCard(
                          context,
                          'Barang Terlaris',
                          '${provider.mostSoldProduct?['name'] ?? '0'}',
                        ),
                        const SizedBox(height: 16),

                        // Chart Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weekly Totals
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Pendapatan Minggu Ini (${summary['start_of_week']} - ${summary['end_of_week']})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Product Details Table

                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: [
                                ColumnSeries<dynamic, String>(
                                  dataSource:
                                      summary['products'] as List<dynamic>,
                                  xValueMapper: (dynamic product, _) =>
                                      product['product_name'] ?? '',
                                  yValueMapper: (dynamic product, _) =>
                                      product['total_quantity'],
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  });
                },
              ),
              // Statistik Section

              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard(BuildContext context, String title, String value) {
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
