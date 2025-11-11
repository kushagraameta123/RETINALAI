import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  Future<void> loadAppointments({String? status, String? doctorId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Method 1: Try using the new syntax
      PostgrestFilterBuilder query = _supabase
          .from('appointments')
          .select()
          .order('appointment_date');

      // Apply filters using match for equality
      Map<String, dynamic> filters = {};
      if (status != null) filters['status'] = status;
      if (doctorId != null) filters['doctor_id'] = doctorId;

      if (filters.isNotEmpty) {
        query = query.match(filters);
      }

      final data = await query;
      _appointments = data.map((json) => Appointment.fromJson(json)).toList();
    } catch (error) {
      print('Error with method 1: $error');
      
      // Fallback: Load all appointments without filters
      try {
        final data = await _supabase
            .from('appointments')
            .select()
            .order('appointment_date');
            
        _appointments = data.map((json) => Appointment.fromJson(json)).toList();
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        _appointments = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _supabase
          .from('appointments')
          .update({'status': status})
          .eq('id', appointmentId);

      await loadAppointments();
    } catch (error) {
      print('Error updating appointment: $error');
      rethrow;
    }
  }

  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      await _supabase.from('appointments').insert(appointmentData);
      await loadAppointments();
    } catch (error) {
      print('Error creating appointment: $error');
      rethrow;
    }
  }

  // Simple method to load all appointments
  Future<void> loadAllAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('appointments')
          .select()
          .order('appointment_date', ascending: true);

      _appointments = data.map((json) => Appointment.fromJson(json)).toList();
    } catch (error) {
      print('Error loading appointments: $error');
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
