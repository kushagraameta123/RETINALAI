class DoctorInfo {
  final String? specialization;
  final String? licenseNumber;
  final String? qualifications;
  final int? yearsOfExperience;
  final String? hospitalAffiliation;
  final String? bio;
  final bool isApproved;

  DoctorInfo({
    this.specialization,
    this.licenseNumber,
    this.qualifications,
    this.yearsOfExperience,
    this.hospitalAffiliation,
    this.bio,
    this.isApproved = false,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      specialization: json['specialization'],
      licenseNumber: json['license_number'],
      qualifications: json['qualifications'],
      yearsOfExperience: json['years_of_experience'],
      hospitalAffiliation: json['hospital_affiliation'],
      bio: json['bio'],
      isApproved: json['is_approved'] ?? false,
    );
  }
}
