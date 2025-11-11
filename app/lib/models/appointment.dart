import 'app_user.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;
  final String? symptoms;
  final String? diagnosis;
  final String? prescription;
  final String? notes;
  final double consultationFee;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  // You can add patient and doctor objects if needed
  final AppUser? patient;
  final AppUser? doctor;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.symptoms,
    this.diagnosis,
    this.prescription,
    this.notes,
    required this.consultationFee,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      appointmentTime: json['appointment_time'],
      status: json['status'],
      symptoms: json['symptoms'],
      diagnosis: json['diagnosis'],
      prescription: json['prescription'],
      notes: json['notes'],
      consultationFee: (json['consultation_fee'] as num).toDouble(),
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String(),
      'appointment_time': appointmentTime,
      'status': status,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'notes': notes,
      'consultation_fee': consultationFee,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
