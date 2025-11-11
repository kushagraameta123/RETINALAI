import 'package:go_router/go_router.dart';
import 'package:healthcare_app/screens/auth/login_screen.dart';
import 'package:healthcare_app/screens/auth/register_screen.dart';
import 'package:healthcare_app/screens/dashboard_screen.dart';
import 'package:healthcare_app/screens/admin/admin_dashboard.dart';
import 'package:healthcare_app/screens/patient/patient_dashboard.dart';
import 'package:healthcare_app/screens/doctor/doctor_dashboard.dart';
import 'package:healthcare_app/screens/profile/user_profile_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (BuildContext context, GoRouterState state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/patient-dashboard',
      builder: (BuildContext context, GoRouterState state) => const PatientDashboard(),
    ),
    GoRoute(
      path: '/doctor-dashboard',
      builder: (BuildContext context, GoRouterState state) => const DoctorDashboard(),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) => const UserProfileScreen(),
    ),
  ],
);
