import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'buyer';
  String? _location;
  String? _farmDetails;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: Validators.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                  DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
                decoration: const InputDecoration(labelText: 'I am a'),
              ),
              const SizedBox(height: 12),
              if (_selectedRole == 'farmer') ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Farm Details (crops, size, etc.)'),
                  onChanged: (v) => _farmDetails = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Farm Location'),
                  onChanged: (v) => _location = v,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (v) => Validators.confirmPassword(v, _passwordController.text),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: authProvider.isLoading ? 'Registering...' : 'Register',
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);
                        if (_formKey.currentState!.validate()) {
                          final userData = {
                            'name': _nameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'phone': _phoneController.text.trim(),
                            'role': _selectedRole,
                            'password': _passwordController.text,
                            if (_location != null) 'location': _location,
                            if (_farmDetails != null) 'farmDetails': _farmDetails,
                          };
                          final success = await authProvider.register(userData);
                          if (!mounted) return;
                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Account created successfully')),
                            );
                            await Future.delayed(const Duration(milliseconds: 700));
                            final role = authProvider.user!.role;
                            if (!mounted) return;
                            if (role == 'farmer') {
                              router.go('/farmer-dashboard');
                            } else if (role == 'buyer') {
                              router.go('/buyer-dashboard');
                            } else {
                              router.go('/admin-dashboard');
                            }
                          } else {
                            messenger.showSnackBar(
                              SnackBar(content: Text(authProvider.error ?? 'Registration failed')),
                            );
                          }
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}