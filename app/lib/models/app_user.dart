import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

class AppUser {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool isApproved;
  final DoctorInfo? doctorInfo;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.isApproved,
    this.doctorInfo,
  });

  // Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'Unknown User';
  }

  // Get first letter for avatar
  String get firstLetter {
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0];
    } else if (lastName != null && lastName!.isNotEmpty) {
      return lastName![0];
    }
    return 'U';
  }

  factory AppUser.fromSupabase(supabase_auth.User user, Map<String, dynamic> profileData) {
    return AppUser(
      id: user.id,
      email: user.email!,
      role: profileData['role'] ?? 'patient',
      createdAt: DateTime.parse(profileData['created_at'] ?? DateTime.now().toIso8601String()),
      firstName: profileData['first_name'],
      lastName: profileData['last_name'],
      phoneNumber: profileData['phone_number'],
      isApproved: profileData['is_approved'] ?? false,
      doctorInfo: profileData['doctor_info'] != null 
          ? DoctorInfo.fromJson(profileData['doctor_info'])
          : null,
    );
  }
}

class DoctorInfo {
  final String? specialization;
  final String? department;
  final String? licenseNumber;
  final String? hospitalClinic;
  final int? yearsOfExperience;

  DoctorInfo({
    this.specialization,
    this.department,
    this.licenseNumber,
    this.hospitalClinic,
    this.yearsOfExperience,
  });

  // Get hospital name (alias for hospitalClinic)
  String? get hospital => hospitalClinic;

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      specialization: json['specialization'],
      department: json['department'],
      licenseNumber: json['license_number'],
      hospitalClinic: json['hospital_clinic'],
      yearsOfExperience: json['years_of_experience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      'department': department,
      'license_number': licenseNumber,
      'hospital_clinic': hospitalClinic,
      'years_of_experience': yearsOfExperience,
    };
  }
}
