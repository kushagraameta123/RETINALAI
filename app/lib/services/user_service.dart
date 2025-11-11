import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _supabase.from('profiles').select().eq('id', userId).single();
  }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    return await _supabase.from('profiles').select().eq('role', 'doctor');
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await _supabase.from('profiles').update(updates).eq('id', userId);
  }
}
