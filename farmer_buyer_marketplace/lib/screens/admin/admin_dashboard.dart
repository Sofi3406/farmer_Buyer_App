import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: _buildDrawer(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text('Welcome, Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCard('Manage Users', Icons.people, () => context.go('/admin-users')),
                  _buildCard('Manage Listings', Icons.production_quantity_limits, () => context.go('/admin-listings')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          width: 140,
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('FarmConnect Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.go('/admin-dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () => context.go('/admin-users'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Manage Listings'),
            onTap: () => context.go('/admin-listings'),
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