import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:healthcare_app/providers/auth_provider.dart';
import 'package:healthcare_app/widgets/common/custom_text_field.dart';
import 'package:healthcare_app/widgets/common/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: AuthProvider.ADMIN_EMAIL);
  final _passwordController = TextEditingController(text: AuthProvider.ADMIN_PASSWORD);

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Calls the 'login' method, which is now correctly defined in the provider
      final result = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (result['success']) {
        // Use go to clear the login stack
        context.go('/dashboard'); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  Widget _buildLoginFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Admin Hint for Easy Login during Dev/Testing
          Text(
            'Admin: ${AuthProvider.ADMIN_EMAIL} / ${AuthProvider.ADMIN_PASSWORD}',
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            icon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password logic
              },
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return ElevatedButton(
                onPressed: auth.isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              );
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Don\'t have an account? Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your account to continue',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                _buildLoginFields(),
              ],
            ),
          ),
        ),
        webLayout: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 32),
                _buildLoginFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
