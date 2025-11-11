import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;
import '../models/app_user.dart';
import '../services/user/user_service.dart';

class AuthProvider with ChangeNotifier {
  final supabase = supabase_auth.Supabase.instance.client;
  AppUser? _user;
  bool _isLoading = false;

  // Use original constant names for compatibility
  static const String ADMIN_EMAIL = 'admin@healthcare.com';
  static const String ADMIN_PASSWORD = 'superadminpassword'; 

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> _fetchUserProfileAndSetUser(supabase_auth.User supabaseUser) async {
    final Map<String, dynamic> profileData = await UserService().getUserProfile(supabaseUser.id);
    _user = AppUser.fromSupabase(supabaseUser, profileData);
    notifyListeners();
    return {'success': true, 'user': _user};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // ADMIN CHECK
      if (email == ADMIN_EMAIL && password == ADMIN_PASSWORD) {
        _user = AppUser(
          id: 'admin_id_001',
          email: ADMIN_EMAIL,
          role: 'admin',
          createdAt: DateTime.now(),
          firstName: 'Super',
          lastName: 'Admin',
          isApproved: true,
        );
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Admin login successful.'};
      }

      // STANDARD SUPABASE LOGIN
      final supabase_auth.AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final result = await _fetchUserProfileAndSetUser(response.user!);
        
        if (_user!.role == 'doctor' && !_user!.isApproved) {
          await logout(); 
          return {'success': false, 'message': 'Account pending admin approval.'};
        }
        
        return result;
      }
      return {'success': false, 'message': 'Sign-in failed. User data is null.'};
    } on supabase_auth.AuthException catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': error.message};
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. First create the user in Supabase Auth
      final supabase_auth.AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return {'success': false, 'message': 'User registration failed.'};
      }

      final String userId = response.user!.id;
      final String userRole = profileData['role'];

      // 2. Wait a moment to ensure user is created in auth system
      await Future.delayed(const Duration(seconds: 1));

      // 3. INSERT PROFILE (Common data for all users)
      await supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'role': userRole,
        'first_name': profileData['firstName'],
        'last_name': profileData['lastName'],
        'phone_number': profileData['phoneNumber'],
        'is_approved': userRole != 'doctor', // Auto-approve non-doctors
        'created_at': DateTime.now().toIso8601String(),
      });

      // 4. INSERT DOCTOR DATA (If applicable)
      if (userRole == 'doctor') {
        await supabase.from('doctors').insert({
          'profile_id': userId,
          'specialization': profileData['specialization'],
          'department': profileData['department'],
          'license_number': profileData['licenseNumber'],
          'hospital_clinic': profileData['hospitalClinic'],
          'years_of_experience': profileData['yearsOfExperience'],
          'is_approved': false, // Doctor must be approved by admin
        });
      }

      return await _fetchUserProfileAndSetUser(response.user!);
      
    } on supabase_auth.AuthException catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': error.message};
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Registration failed: $error'};
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  // Add method to check auth state on app start
  Future<void> initialize() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      await _fetchUserProfileAndSetUser(currentUser);
    }
  }
}
