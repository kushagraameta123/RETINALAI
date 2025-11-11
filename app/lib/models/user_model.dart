import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

class User { factory User.fromJson(Map<String, dynamic> json) { return User(id: json['id'] as String, email: json['email'] as String, role: json['role'] as String, profile: UserProfile.fromJson(json), doctorInfo: json['role'] == 'doctor' ? DoctorInfo.fromJson(json) : null, ); }
  final String id;
  final String email;
  final String role;
  final UserProfile? profile;
  final DoctorInfo? doctorInfo;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.profile,
    this.doctorInfo,
  });

  factory User.fromSupabaseUser(supabase_auth.User supabaseUser, Map<String, dynamic> profileData) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email!,
      role: profileData['role'] as String,
      profile: UserProfile.fromJson(profileData),
      doctorInfo: profileData['role'] == 'doctor' ? DoctorInfo.fromJson(profileData) : null,
    );
  }
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  UserProfile({required this.firstName, required this.lastName, this.avatarUrl});

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class DoctorInfo {
  final String specialization;
  final String hospital;
  final bool isApproved;

  DoctorInfo({required this.specialization, required this.hospital, this.isApproved = false});

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      specialization: json['specialization'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      isApproved: json['is_approved'] as bool? ?? false,
    );
  }
}
