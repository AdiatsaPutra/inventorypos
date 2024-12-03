import 'package:flutter/material.dart';
import 'package:inventorypos/pages/inventory_page.dart';
import 'package:inventorypos/pages/pos_overview_page.dart';
import 'package:inventorypos/pages/pos_page.dart';
import 'package:inventorypos/pages/service_page.dart';
import 'package:inventorypos/pages/transaction_page.dart';

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
    'Point of Sale Overview',
    'Inventory',
    'Transaction',
    'Service',
    'Point of Sale', // New title added here
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                leading: IconButton(
                  icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu),
                  onPressed: _toggleDrawer,
                ),
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
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: Text(
                'POS Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(0),
          ),
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.white),
            title:
                const Text('Inventory', style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(1),
          ),
          ListTile(
            leading: const Icon(Icons.receipt, color: Colors.white),
            title: const Text('Transaction',
                style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(2),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Service', style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(3),
          ),
          ListTile(
            leading: const Icon(Icons.local_mall,
                color: Colors.white), // Icon for POS
            title: const Text('Point of Sale',
                style: TextStyle(color: Colors.white)),
            onTap: () => _onTabSelected(4), // Navigate to POS tab
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
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
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.inventory,
            label: 'Inventory',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.receipt,
            label: 'Transaction',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: 'Service',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.local_mall, // Icon for POS
            label: 'POS',
            index: 4, // Index for POS tab
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
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
