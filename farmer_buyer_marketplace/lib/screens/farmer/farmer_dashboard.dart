import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Dashboard')),
      drawer: _buildDrawer(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.agriculture, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Welcome, Farmer!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Products', '12', Icons.eco),
                  _buildStatCard('Orders', '5', Icons.shopping_cart),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text('FarmConnect', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.go('/farmer-dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Product'),
            onTap: () => context.go('/farmer-add-product'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Products'),
            onTap: () => context.go('/farmer-products'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Orders Received'),
            onTap: () => context.go('/farmer-orders'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => context.go('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}