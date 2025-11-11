import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appointment_model.dart';
import 'main.dart'; // For UserRole and colors

class AdminDoctorRegistrationPage extends StatefulWidget {
  const AdminDoctorRegistrationPage({super.key});

  @override
  State<AdminDoctorRegistrationPage> createState() => _AdminDoctorRegistrationPageState();
}

class _AdminDoctorRegistrationPageState extends State<AdminDoctorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedSpecialty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Ensure specialties are loaded for the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchAvailableDoctors();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialization.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    // This function will attempt to link the email to a Supabase user and create a profile entry.
    final success = await provider.registerExistingUserAsProvider(
      _emailController.text.trim(),
      _nameController.text.trim(),
      _selectedSpecialty!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor ${_nameController.text} successfully registered as Provider!')),
      );
      // Automatically refresh the Admin Dashboard profile list
      await provider.fetchAllProfiles(); 
      Navigator.pop(context); 
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Ensure user exists and profile is unique.')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Doctor'),
        foregroundColor: primaryBlue,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Onboard New Healthcare Provider',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // 1. Email Input (Must be an existing Supabase user)
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Existing User Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Enter a valid email.' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // 2. Full Name Input
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Doctor\'s Full Name',
                      prefixIcon: const Icon(Icons.person_pin),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the doctor\'s name.' : null,
                  ),
                  const SizedBox(height: 20),

                  // 3. Specialization Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Ophthalmology Specialization',
                      prefixIcon: const Icon(Icons.medical_services, color: accentGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    initialValue: _selectedSpecialty,
                    items: provider.specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecialty = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Specialization is required.' : null,
                    hint: provider.isLoading ? const Text('Loading specialties...') : const Text('Select a category'),
                  ),
                  
                  const SizedBox(height: 30),

                  // 4. Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _registerDoctor,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Register Doctor'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
