import 'package:flutter/material.dart';
import 'main.dart'; // To access the global 'supabase' getter

// Define the appointment status enum
enum AppointmentStatus {
  pending,
  approved,
  rejected,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String toDisplayString() {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
      case AppointmentStatus.rejected:
        return 'Rejected';
    }
  }
}

// Doctor model to hold provider data and specialty (Used for patient booking and admin viewing)
class Doctor {
  final String id;
  final String fullName;
  final String specialization;
  final String role; 
  final String? email; 

  Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.role,
    this.email,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      fullName: json['full_name'] ?? 'User ID: ${json['id'].toString().substring(0, 8)}',
      specialization: json['specialization'] ?? 'N/A',
      role: json['role'] ?? 'Patient',
      email: json['email'],
    );
  }
}

// Data model for an appointment
class Appointment {
  final int id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final DateTime appointmentTime;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.appointmentTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] ?? 'Unknown Patient', 
      doctorId: json['doctor_id'] as String,
      appointmentTime: DateTime.parse(json['appointment_time'] as String),
      status: AppointmentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => AppointmentStatus.pending),
    );
  }
}

// Provider for managing appointment state and interaction with Supabase
class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _patientAppointments = [];
  List<Doctor> _availableDoctors = [];
  List<Doctor> _allProfiles = []; 
  bool _isLoading = false;

  List<Appointment> get pendingAppointments => _pendingAppointments;
  List<Appointment> get patientAppointments => _patientAppointments;
  List<Doctor> get availableDoctors => _availableDoctors;
  List<Doctor> get allProfiles => _allProfiles; 
  bool get isLoading => _isLoading;
  
  // List of all unique specialties (categories)
  List<String> get specialties {
    final dbSpecialties = _availableDoctors
        .map((d) => d.specialization)
        .where((s) => s != 'N/A')
        .toSet();
        
    return {...defaultOphthalmologySpecialties, ...dbSpecialties}.toList();
  }
  
  // Maps specialty (category) to a list of available doctors
  Map<String, List<Doctor>> get doctorsByCategory {
    final Map<String, List<Doctor>> map = {};
    for (var specialty in specialties) {
      map[specialty] = _availableDoctors
          .where((d) => d.specialization == specialty)
          .toList();
    }
    return map;
  }

  // --- Doctor Name Resolver ---
  String getDoctorFullName(String doctorId) {
    final doctor = _availableDoctors.firstWhere(
      (d) => d.id == doctorId,
      orElse: () => Doctor(id: doctorId, fullName: 'Unknown Doctor', specialization: 'N/A', role: 'Provider'),
    );
    return doctor.fullName;
  }
  // --------------------------


  // --- Static Default Specialties ---
  static const List<String> defaultOphthalmologySpecialties = [
    'General Ophthalmology',
    'Retina Specialist (Retinology)',
    'Glaucoma Specialist',
    'Cataract & Lens Implant',
    'Cornea & External Disease',
    'Pediatric Ophthalmology',
    'Oculoplastics & Orbital Surgery',
    'Neuro-Ophthalmology',
  ];
  // ----------------------------------------

  // --- Management Logic (Update Role/Specialty) ---
  Future<bool> updateUserProfile({
    required String userId,
    String? newRole,
    String? newSpecialization,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updateData = <String, dynamic>{};
      if (newRole != null) updateData['role'] = newRole;
      if (newSpecialization != null) updateData['specialization'] = newSpecialization;

      if (updateData.isNotEmpty) {
        await supabase.from('profiles').update(updateData).eq('id', userId);
      }
      
      // Refresh all user lists to reflect the changes immediately
      await fetchAllProfiles();
      await fetchAvailableDoctors();

      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // --- Profile Check and Creation Logic ---
  Future<Doctor?> fetchProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id, full_name, specialization, role, email')
          .eq('id', userId)
          .single();
      
      return Doctor.fromJson(response);
    } catch (e) {
      debugPrint('Profile not found for $userId: $e');
      return null;
    }
  }

  Future<bool> createProfile(String userId, String name, String specialization, String role) async {
    try {
      await supabase.from('profiles').insert({
        'id': userId,
        'full_name': name,
        'specialization': specialization,
        'role': role,
      });
      await fetchAvailableDoctors();
      return true;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      return false;
    }
  }
  
  // --- Register Doctor Logic (Admin Feature) ---
  Future<bool> registerExistingUserAsProvider(String email, String name, String specialization) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Fetch the user's ID using their email (Requires RLS set up or a Server/Edge Function)
      // NOTE: This relies on the 'profiles' table having an 'email' field and Admin RLS access.
      final userResponse = await supabase.from('profiles') 
          .select('id, email')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null || userResponse['id'] == null) {
          throw Exception('User not found in profiles table. Ensure user has logged in once.');
      }
      
      final userId = userResponse['id'] as String;

      // 2. Upsert the profile entry for that user ID (update if exists, insert if not)
      await supabase
          .from('profiles')
          .upsert({
              'id': userId,
              'full_name': name,
              'specialization': specialization,
              'role': 'Provider',
              'email': email,
          }, onConflict: 'id'); 
      
      await fetchAvailableDoctors();
      return true;

    } catch (e) {
      debugPrint('Error registering doctor profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // --- END NEW: Register Doctor Logic ---


  // --- Future-based fetching (Patient Dashboard) ---
  Future<void> fetchPatientAppointments(String patientId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await supabase
          .from('appointments')
          .select('*')
          .eq('patient_id', patientId)
          .order('appointment_time', ascending: true);

      _patientAppointments = (response as List).map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching patient appointments: $e');
      _patientAppointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // --- Future-based fetching (Admin Dashboard) ---
  Future<void> fetchAllProfiles() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await supabase
          .from('profiles')
          .select('id, full_name, specialization, role, email') 
          .order('role', ascending: true);

      _allProfiles = (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching all profiles: $e');
      _allProfiles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // --- Future-based fetching (All Available Doctors - Patient Booking) ---
  Future<void> fetchAvailableDoctors() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await supabase
          .from('profiles')
          .select('id, full_name, specialization, role')
          .eq('role', 'Provider'); 

      _availableDoctors = (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching available doctors: $e');
      _availableDoctors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Future-based fetching (Doctor/Provider Dashboard) ---
  Future<void> fetchPendingAppointments(String doctorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await supabase
          .from('appointments')
          .select('*')
          .eq('doctor_id', doctorId)
          .eq('status', 'pending')
          .order('appointment_time', ascending: true);

      _pendingAppointments = (response as List).map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching pending appointments: $e');
      _pendingAppointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Patient Booking Logic (Remains simple insert) ---
  Future<bool> bookAppointment(String patientId, DateTime time, String doctorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final patientEmail = supabase.auth.currentUser?.email ?? 'Unknown Patient';

      await supabase.from('appointments').insert({
        'patient_id': patientId,
        'patient_name': patientEmail, 
        'doctor_id': doctorId,
        'appointment_time': time.toIso8601String(),
        'status': AppointmentStatus.pending.toString().split('.').last,
      });
      
      await fetchPatientAppointments(patientId);

      return true;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Doctor Action Logic (Now requires manual refresh after update) ---
  Future<void> updateAppointmentStatus(int appointmentId, AppointmentStatus newStatus, String doctorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await supabase.from('appointments').update({
        'status': newStatus.toString().split('.').last,
      }).eq('id', appointmentId);

      await fetchPendingAppointments(doctorId);

    } catch (e) {
      debugPrint('Error updating appointment status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
