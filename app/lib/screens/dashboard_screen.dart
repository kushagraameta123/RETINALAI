import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in'),
        ),
      );
    }

    // Redirect based on user role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (user.role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 'doctor':
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
          break;
        case 'patient':
        default:
          Navigator.pushReplacementNamed(context, '/patient-dashboard');
          break;
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
