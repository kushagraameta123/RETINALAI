import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    // Select all profile columns and join the 'doctors' table (one-to-one join)
    final response = await supabase
        .from('profiles')
        .select('*, doctors(*)') 
        .eq('id', userId)
        .single();
    return response;
  }
  
  Future<List<Map<String, dynamic>>> getDoctors() async {
    // Fetches all doctors and their approval status
    final response = await supabase
        .from('profiles')
        .select('*, doctors(*)')
        .eq('role', 'doctor');
    return response;
  }
  
  Future<List<Map<String, dynamic>>> getPendingDoctors() async {
    // Fetches doctors where the joined 'doctors' table explicitly has is_approved = false
    final response = await supabase
        .from('profiles')
        .select('*, doctors!inner(*)') // Inner join on doctors where a match exists
        .eq('role', 'doctor')
        .eq('doctors.is_approved', false); // Filter on the joined table's column
    return response;
  }
}
