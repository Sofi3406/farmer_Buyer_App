import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Back')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : 'Password must be at least 6 characters',
              ),
              const SizedBox(height: 24),
              if (authProvider.isLoading)
                const LoadingIndicator()
              else
                CustomButton(
                  text: 'Login',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await authProvider.login(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      if (success && mounted) {
                        final role = authProvider.user!.role;
                        if (role == 'farmer') context.go('/farmer-dashboard');
                        else if (role == 'buyer') context.go('/buyer-dashboard');
                        else context.go('/admin-dashboard');
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.error ?? 'Login failed')),
                        );
                      }
                    }
                  },
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}