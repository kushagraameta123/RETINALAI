import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'appointment_model.dart';
import 'main.dart'; // To access the color constants and UserRole enum
import 'admin_doctor_registration_page.dart'; // NEW: Import for doctor registration

class ProviderDashboard extends StatefulWidget {
  final String doctorId;
  const ProviderDashboard({super.key, required this.doctorId});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {

  @override
  void initState() {
    super.initState();
    // Fetch appointments immediately when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false)
          .fetchPendingAppointments(widget.doctorId);
    });
  }

  void _showStatusUpdateMessage(BuildContext context, String action, String patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$patient\'s appointment has been $action.'),
        backgroundColor: action == 'approved' ? accentGreen : Colors.red,
      ),
    );
  }

  Future<void> _refreshAppointments() async {
    await Provider.of<AppointmentProvider>(context, listen: false)
        .fetchPendingAppointments(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);
    final currentDoctorId = widget.doctorId;
    
    // Filter and group appointments
    final today = provider.pendingAppointments.where((a) => a.appointmentTime.day == DateTime.now().day).toList();
    final tomorrow = provider.pendingAppointments.where((a) => a.appointmentTime.day == DateTime.now().add(const Duration(days: 1)).day).toList();
    final future = provider.pendingAppointments.where((a) => a.appointmentTime.isAfter(DateTime.now().add(const Duration(days: 1)))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Pending Appointment Requests',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
        
        Expanded(
          child: provider.isLoading && provider.pendingAppointments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshAppointments,
                  child: provider.pendingAppointments.isEmpty 
                      ? ListView(children: const [
                          Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No pending appointment requests at this time.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ])
                      : ListView(
                          children: [
                            if (today.isNotEmpty)
                              _buildAppointmentGroup(context, 'Appointments Today (${today.length})', today, provider, currentDoctorId),
                            
                            if (tomorrow.isNotEmpty)
                              _buildAppointmentGroup(context, 'Appointments Tomorrow (${tomorrow.length})', tomorrow, provider, currentDoctorId),

                            if (future.isNotEmpty)
                              _buildAppointmentGroup(context, 'Future Requests (${future.length})', future, provider, currentDoctorId),
                          ],
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildAppointmentGroup(BuildContext context, String title, List<Appointment> appointments, AppointmentProvider provider, String currentDoctorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: accentGreen),
          ),
        ),
        ...appointments.map((appointment) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryBlue.withOpacity(0.1),
                child: const Icon(Icons.person, color: primaryBlue),
              ),
              title: Text(
                appointment.patientName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Time: ${DateFormat.jm().format(appointment.appointmentTime)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Approve Button
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: accentGreen),
                    tooltip: 'Approve',
                    onPressed: provider.isLoading ? null : () async {
                      await provider.updateAppointmentStatus(
                        appointment.id, 
                        AppointmentStatus.approved,
                        currentDoctorId,
                      );
                      _showStatusUpdateMessage(context, 'approved', appointment.patientName);
                    },
                  ),
                  // Reject Button
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Reject',
                    onPressed: provider.isLoading ? null : () async {
                      await provider.updateAppointmentStatus(
                        appointment.id, 
                        AppointmentStatus.rejected,
                        currentDoctorId,
                      );
                      _showStatusUpdateMessage(context, 'rejected', appointment.patientName);
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// --- Administrator Dashboard (Functional and Manual Fetch) ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  @override
  void initState() {
    super.initState();
    // Fetch all profiles immediately when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchAllProfiles();
    });
  }

  Future<void> _refreshProfiles() async {
    await Provider.of<AppointmentProvider>(context, listen: false).fetchAllProfiles();
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);
    
    final patients = provider.allProfiles.where((p) => p.role == UserRole.Patient.toString().split('.').last).toList();
    final providers = provider.allProfiles.where((p) => p.role == UserRole.Provider.toString().split('.').last).toList();
    final admins = provider.allProfiles.where((p) => p.role == UserRole.Admin.toString().split('.').last).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'System User Overview',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),
          
          // NEW: Register Doctor Button
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminDoctorRegistrationPage()),
                );
                // Refresh data after returning from registration page
                _refreshProfiles();
              },
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Register New Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),


          Expanded(
            child: provider.isLoading && provider.allProfiles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshProfiles,
                  child: ListView(
                    children: [
                      // List of all doctor specialties/categories
                      _buildSpecialtyCategoryCard(context, 'Ophthalmology Specialties', provider.specialties),
                      
                      // User Lists
                      _buildUserListCard(context, 'Healthcare Providers (${providers.length})', providers, Icons.local_hospital, accentGreen),
                      _buildUserListCard(context, 'Registered Patients (${patients.length})', patients, Icons.person_outline, primaryBlue),
                      _buildUserListCard(context, 'System Administrators (${admins.length})', admins, Icons.shield_outlined, Colors.black),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialtyCategoryCard(BuildContext context, String title, List<String> specialties) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.category, color: primaryBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        children: specialties.map((specialty) {
          return ListTile(
            title: Text(specialty),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserListCard(BuildContext context, String title, List<Doctor> users, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        children: users.map((user) {
          return ListTile(
            title: Text(user.fullName),
            subtitle: Text(user.specialization != 'N/A' ? user.specialization : 'User ID: ${user.id.substring(0, 8)}...'),
            trailing: Text(user.role),
          );
        }).toList(),
      ),
    );
  }
}
