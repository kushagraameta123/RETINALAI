import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'appointment_model.dart';
import 'main.dart';
// Import to use the PatientDashboard elsewhere

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Doctor? _selectedDoctor;
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    // Fetch doctors immediately when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchAvailableDoctors();
    });
  }

  Future<void> _selectDateTime() async {
    // Picker logic remains the same
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryBlue,
                onPrimary: Colors.white,
                onSurface: primaryBlue,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submitAppointment() async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Doctor, Date, and Time.')),
      );
      return;
    }

    final DateTime finalAppointmentTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    final success = await Provider.of<AppointmentProvider>(context, listen: false).bookAppointment(
      patientId,
      finalAppointmentTime,
      _selectedDoctor!.id,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Appointment requested for Dr. ${_selectedDoctor!.fullName} (${_selectedDoctor!.specialization})! Status: Pending'),
            backgroundColor: accentGreen),
      );
      Navigator.pop(context); // Go back to Patient Dashboard
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to book appointment. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);
    
    // Filter doctors based on selected specialty
    final filteredDoctors = provider.availableDoctors
        .where((doctor) => _selectedSpecialty == null || doctor.specialization == _selectedSpecialty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book New Appointment'),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Book Your Specialist Consultation',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // --- Specialty Filter Dropdown (Categories) ---
                if (provider.specialties.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Doctor Category (Specialty)',
                      prefixIcon: const Icon(Icons.category, color: accentGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    initialValue: _selectedSpecialty,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Specialties')),
                      ...provider.specialties.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecialty = newValue;
                        _selectedDoctor = null; // IMPORTANT: Reset doctor selection when specialty changes
                      });
                    },
                  )
                else if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else 
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('No specialties available.', style: TextStyle(color: Colors.red)),
                  ),
                
                const SizedBox(height: 16),

                // --- Doctor Selection Dropdown (Available Doctors in Category) ---
                DropdownButtonFormField<Doctor>(
                  decoration: InputDecoration(
                    labelText: filteredDoctors.isEmpty && !provider.isLoading 
                        ? (_selectedSpecialty != null ? 'No Doctors in this Category' : 'No Registered Doctors Available')
                        : 'Select Available Doctor',
                    prefixIcon: const Icon(Icons.local_hospital, color: primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  initialValue: _selectedDoctor,
                  items: filteredDoctors.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor,
                      child: Text(doctor.fullName),
                    );
                  }).toList(),
                  onChanged: (Doctor? newValue) {
                    setState(() {
                      _selectedDoctor = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a doctor.' : null,
                  isExpanded: true,
                  hint: filteredDoctors.isEmpty && _selectedSpecialty != null
                      ? const Text('Filter to see available doctors.') 
                      : null,
                  menuMaxHeight: 300,
                ),
                const SizedBox(height: 24),
                
                // Date/Time Display and Picker Button
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointment Time:',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null 
                                  ? 'No time selected'
                                  : '${DateFormat.yMMMd().format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : _selectDateTime,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Select'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),

                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (provider.isLoading || _selectedDoctor == null) ? null : _submitAppointment,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Confirm Appointment Request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
