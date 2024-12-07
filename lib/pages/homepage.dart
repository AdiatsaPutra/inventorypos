import 'package:flutter/material.dart';
import 'package:inventorypos/pages/inventory_page.dart';
import 'package:inventorypos/pages/login_page.dart';
import 'package:inventorypos/pages/pos_overview_page.dart';
import 'package:inventorypos/pages/pos_page.dart';
import 'package:inventorypos/pages/service_page.dart';
import 'package:inventorypos/pages/transaction_page.dart';
import 'package:inventorypos/provider/dashboard_provider.dart';
import 'package:inventorypos/provider/inventory_provider.dart';
import 'package:inventorypos/provider/pos_provider.dart';
import 'package:inventorypos/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  _POSHomePageState createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  int _currentIndex = 0;
  bool _isDrawerOpen = false;

  final List<Widget> _pages = [
    POSOverviewPage(),
    InventoryPage(),
    TransactionPage(),
    ServicePage(),
    POSPage(), // New POS Page added here
  ];

  final List<String> _titles = [
    'Beranda',
    'Inventaris',
    'Transaksi',
    'Service',
    'Kasir', // New title added here
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _hideDrawer();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _hideDrawer() {
    setState(() {
      _isDrawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          GestureDetector(
            onTap: _hideDrawer,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  _titles[_currentIndex],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ), // Dynamic title
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/logo/sasa.png'),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isDrawerOpen ? Icons.close : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: _toggleDrawer,
                  ),
                ],
                backgroundColor: Theme.of(context).primaryColor,
              ),
              body: _pages[_currentIndex],
              bottomNavigationBar: _buildCustomBottomNavBar(),
            ),
          ),

          // Custom Drawer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: _buildCustomDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawer() {
    return Container(
      width: 250,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          SizedBox(height: 16),
          Image.asset(
            'assets/logo/sasa.png',
            width: 100,
            height: 100,
          ),
          SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Beranda', style: TextStyle(color: Colors.white)),
            onTap: () {
              final dashboardProvider =
                  Provider.of<DashboardProvider>(context, listen: false);
              dashboardProvider.fetchTotalOfAllTransactions();
              dashboardProvider.fetchMostSoldProduct();
              dashboardProvider.fetchTotalProductsSold();
              dashboardProvider.fetchWeeklyProductsSold();
              _onTabSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.white),
            title:
                const Text('Inventaris', style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(1),
          ),
          ListTile(
            leading: const Icon(Icons.receipt, color: Colors.white),
            title:
                const Text('Transaksi', style: TextStyle(color: Colors.white)),
            onTap: () {
              final transactionProvider =
                  Provider.of<TransactionProvider>(context, listen: false);
              transactionProvider.fetchTransactions();
              _onTabSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Layanan', style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(3),
          ),
          ListTile(
            leading: const Icon(Icons.local_mall,
                color: Colors.white), // Icon for POS
            title: const Text('Kasir', style: TextStyle(color: Colors.white)),
            onTap: () {
              final inventoryProvider = Provider.of<InventoryProvider>(context);
              inventoryProvider.fetchProducts();
              _onTabSelected(4);
            }, // Navigate to POS tab
          ),
          ListTile(
              leading:
                  const Icon(Icons.logout, color: Colors.white), // Icon for POS
              title:
                  const Text('Keluar', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Future.delayed(Duration(seconds: 2)).then(
                  (value) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                );
              } // Navigate to POS tab
              ),
          SizedBox(height: 16),
          Text(
            'Created by Adiatsa Putra Santika, S.Kom.',
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Beranda',
            index: 0,
            onTap: () {
              final dashboardProvider =
                  Provider.of<DashboardProvider>(context, listen: false);
              dashboardProvider.fetchTotalOfAllTransactions();
              dashboardProvider.fetchMostSoldProduct();
              dashboardProvider.fetchTotalProductsSold();
              dashboardProvider.fetchWeeklyProductsSold();
              _onTabSelected(0);
            },
          ),
          _buildNavItem(
            icon: Icons.inventory,
            label: 'Inventaris',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.receipt,
            label: 'Transaksi',
            index: 2,
            onTap: () {
              final transactionProvider =
                  Provider.of<TransactionProvider>(context, listen: false);
              transactionProvider.fetchTransactions();
              _onTabSelected(2);
            },
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: 'Layanan',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.local_mall, // Icon for POS
            label: 'Kasir',
            onTap: () {
              final posProvider =
                  Provider.of<POSProvider>(context, listen: false);
              posProvider.initialize(context);
              _onTabSelected(4);
            },
            index: 4, // Index for POS tab
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onTap,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: onTap ?? () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[300],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
