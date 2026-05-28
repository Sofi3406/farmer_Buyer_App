import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUser();
    if (!mounted) return;
    if (authProvider.isAuthenticated) {
      final role = authProvider.user!.role;
      if (role == 'farmer') context.go('/farmer-dashboard');
      else if (role == 'buyer') context.go('/buyer-dashboard');
      else context.go('/admin-dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text('FarmConnect', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}