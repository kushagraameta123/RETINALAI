import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'appointment_model.dart';
import 'main.dart';
import 'book_appointment_page.dart';

class PatientDashboard extends StatefulWidget {
  final String patientId;
  const PatientDashboard({super.key, required this.patientId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch patient's appointments when the dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false)
          .fetchPatientAppointments(widget.patientId);
    });
  }
  
  // Refreshes data when the user pulls down
  Future<void> _refreshAppointments() async {
    await Provider.of<AppointmentProvider>(context, listen: false)
        .fetchPatientAppointments(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${supabase.auth.currentUser?.email ?? 'Patient'}!',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () async {
                  // Navigate and wait for the result (in case an appointment was booked)
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
                  );
                  // Refresh the list after returning from the booking screen
                  _refreshAppointments(); 
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Book New Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Appointments',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        Expanded(
          child: provider.isLoading && provider.patientAppointments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshAppointments,
                  child: provider.patientAppointments.isEmpty
                      ? ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text('You have no appointments scheduled.'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: provider.patientAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = provider.patientAppointments[index];
                            return AppointmentTile(appointment: appointment);
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  const AppointmentTile({super.key, required this.appointment});

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.approved:
        return Colors.green.shade600;
      case AppointmentStatus.rejected:
        return Colors.red.shade600;
      case AppointmentStatus.pending:
      default:
        return Colors.amber.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          appointment.status == AppointmentStatus.approved 
              ? Icons.check_circle_outline 
              : Icons.access_time, 
          color: statusColor,
        ),
        title: Text(
          'Dr. [Provider ID: ${appointment.doctorId.substring(0, 8)}...]', // Displaying Doctor ID placeholder
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat.yMMMMEEEEd().add_jm().format(appointment.appointmentTime),
          style: TextStyle(color: Colors.grey.shade700),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            appointment.status.toDisplayString(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
