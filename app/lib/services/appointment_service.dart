import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAppointments({String? status}) async {
    final query = _supabase.from('appointments').select('''
      *, 
      doctor_profile:profiles!appointments_doctor_id_fkey(*),
      patient_profile:profiles!appointments_patient_id_fkey(*)
    ''');

    if (status != null) {
      return await query.eq('status', status);
    }

    return await query;
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> appointmentData) async {
    return await _supabase.from('appointments').insert(appointmentData).select().single();
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> updates) async {
    await _supabase.from('appointments').update(updates).eq('id', id);
  }
}
