class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? emergencyContact;

  UserProfile({
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.emergencyContact,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      address: json['address'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      gender: json['gender'],
      emergencyContact: json['emergency_contact'],
    );
  }
}
