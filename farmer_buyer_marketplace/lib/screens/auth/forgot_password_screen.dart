import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(_emailController.text.trim());
      setState(() => _emailSent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            if (!_emailSent) ...[
              const Text('Enter your email address and we\'ll send you a link to reset your password.'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Sending...' : 'Send Reset Link',
                onPressed: _resetPassword,
              ),
            ] else ...[
              const Icon(Icons.email, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Password reset link sent!', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              const Text('Please check your email inbox.'),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Back to Login',
                onPressed: () => context.go('/login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}