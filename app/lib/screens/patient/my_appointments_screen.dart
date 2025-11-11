import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  int _selectedTab = 0; // 0: Upcoming, 1: Past

  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'id': '1',
      'doctor': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': '10:00 AM',
      'status': 'confirmed',
      'type': 'In-person',
      'location': 'Main Hospital, Room 205',
    },
    {
      'id': '2',
      'doctor': 'Dr. Michael Chen',
      'specialty': 'Neurologist',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '2:30 PM',
      'status': 'confirmed',
      'type': 'Video Call',
      'location': 'Telemedicine',
    },
    {
      'id': '3',
      'doctor': 'Dr. Emily Davis',
      'specialty': 'Dermatologist',
      'date': DateTime.now().add(const Duration(days: 7)),
      'time': '11:15 AM',
      'status': 'pending',
      'type': 'In-person',
      'location': 'Skin Clinic, Room 101',
    },
  ];

  final List<Map<String, dynamic>> _pastAppointments = [
    {
      'id': '4',
      'doctor': 'Dr. Robert Wilson',
      'specialty': 'Orthopedic',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'time': '9:00 AM',
      'status': 'completed',
      'type': 'In-person',
      'diagnosis': 'Sprained ankle',
      'prescription': 'Rest, ice, compression, elevation',
    },
    {
      'id': '5',
      'doctor': 'Dr. Lisa Martinez',
      'specialty': 'Pediatrician',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'time': '3:45 PM',
      'status': 'completed',
      'type': 'Video Call',
      'diagnosis': 'Regular checkup',
      'prescription': 'Continue current vitamins',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/book-appointment');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 0),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 0 ? Colors.blue.shade50 : Colors.transparent,
                      foregroundColor: _selectedTab == 0 ? Colors.blue.shade700 : Colors.grey.shade600,
                    ),
                    child: Text('Upcoming (${_upcomingAppointments.length})'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 1 ? Colors.blue.shade50 : Colors.transparent,
                      foregroundColor: _selectedTab == 1 ? Colors.blue.shade700 : Colors.grey.shade600,
                    ),
                    child: Text('Past (${_pastAppointments.length})'),
                  ),
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: _selectedTab == 0
                ? _buildAppointmentsList(_upcomingAppointments, isUpcoming: true)
                : _buildAppointmentsList(_pastAppointments, isUpcoming: false),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments, {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming appointments' : 'No past appointments',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming ? 'Book your first appointment to get started' : 'Your completed appointments will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            if (isUpcoming)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/book-appointment');
                },
                child: const Text('Book Appointment'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment, isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, {required bool isUpcoming}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Doctor Info and Status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['doctor'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment['specialty'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(appointment['status']),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Appointment Details
            Row(
              children: [
                _buildDetailItem(Icons.calendar_today, 
                    DateFormat('MMM dd, yyyy').format(appointment['date'])),
                _buildDetailItem(Icons.access_time, appointment['time']),
                _buildDetailItem(Icons.video_call, appointment['type']),
              ],
            ),

            const SizedBox(height: 12),

            // Location/Diagnosis
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isUpcoming ? appointment['location'] : (appointment['diagnosis'] ?? 'No diagnosis'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),

            if (!isUpcoming && appointment['prescription'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.medication, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment['prescription'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            if (isUpcoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showAppointmentActions(appointment);
                      },
                      child: const Text('Manage'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Join video call or get directions
                        if (appointment['type'] == 'Video Call') {
                          _joinVideoCall(appointment);
                        } else {
                          _getDirections(appointment);
                        }
                      },
                      child: Text(appointment['type'] == 'Video Call' ? 'Join Call' : 'Directions'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _viewMedicalRecord(appointment);
                      },
                      child: const Text('View Record'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _bookFollowUp(appointment);
                      },
                      child: const Text('Book Follow-up'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentActions(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Reschedule Appointment'),
              onTap: () {
                Navigator.pop(context);
                _rescheduleAppointment(appointment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel Appointment'),
              onTap: () {
                Navigator.pop(context);
                _cancelAppointment(appointment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Message Doctor'),
              onTap: () {
                Navigator.pop(context);
                _messageDoctor(appointment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Set Reminder'),
              onTap: () {
                Navigator.pop(context);
                _setReminder(appointment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _rescheduleAppointment(Map<String, dynamic> appointment) {
    // TODO: Implement reschedule logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: const Text('This feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: Text('Are you sure you want to cancel your appointment with ${appointment['doctor']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _messageDoctor(Map<String, dynamic> appointment) {
    // TODO: Implement messaging
    Navigator.pushNamed(context, '/chat/1');
  }

  void _setReminder(Map<String, dynamic> appointment) {
    // TODO: Implement reminder setting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder set for 1 hour before appointment'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _joinVideoCall(Map<String, dynamic> appointment) {
    // TODO: Implement video call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining video call with ${appointment['doctor']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _getDirections(Map<String, dynamic> appointment) {
    // TODO: Implement directions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to ${appointment['location']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewMedicalRecord(Map<String, dynamic> appointment) {
    // TODO: Implement medical record view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Record'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Doctor: ${appointment['doctor']}'),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(appointment['date'])}'),
              Text('Diagnosis: ${appointment['diagnosis']}'),
              Text('Prescription: ${appointment['prescription']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _bookFollowUp(Map<String, dynamic> appointment) {
    // TODO: Implement follow-up booking
    Navigator.pushNamed(context, '/book-appointment');
  }
}
