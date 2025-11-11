import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    // Use the simple method without filters for now
    Provider.of<AppointmentProvider>(context, listen: false).loadAllAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadAppointments();
            },
            child: ListView.builder(
              itemCount: provider.appointments.length,
              itemBuilder: (context, index) {
                final appointment = provider.appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Appointment ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${_formatDate(appointment.appointmentDate)}'),
                        Text('Time: ${appointment.appointmentTime}'),
                        Text('Status: ${appointment.status}'),
                        Text('ID: ${appointment.id.substring(0, 8)}...'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (appointment.status == 'scheduled')
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _updateAppointmentStatus(appointment.id, 'confirmed'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _updateAppointmentStatus(appointment.id, 'cancelled'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to retina diagnosis screen
          // Navigator.push(context, MaterialPageRoute(builder: (context) => RetinaDiagnosisScreen()));
        },
        tooltip: 'Retina Diagnosis',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .updateAppointmentStatus(appointmentId, status);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $status')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}
