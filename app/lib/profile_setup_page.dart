import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appointment_model.dart';
import 'main.dart'; // For UserRole and colors

class ProfileSetupPage extends StatefulWidget {
  final UserRole role;

  const ProfileSetupPage({super.key, required this.role}); 

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedSpecialty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Fetch doctor categories for the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchAvailableDoctors();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.role != UserRole.Patient && _selectedSpecialty == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialization.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await provider.createProfile(
      userId,
      _nameController.text.trim(),
      _selectedSpecialty ?? 'General', // Default specialization for Patient/Admin if not a Provider
      widget.role.toString().split('.').last,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.role.toDisplayString()} profile created successfully!')),
      );
      // Redirect to the main dashboard after profile creation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(role: widget.role)),
      );
    } else {
      setState(() => _isSubmitting = false);
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role.toDisplayString()} Setup'),
        automaticallyImplyLeading: false,
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
                    'Complete Your Profile',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'As a ${widget.role.toDisplayString()}, please provide your name and specialization details.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // 1. Full Name Input
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your full name.' : null,
                  ),
                  const SizedBox(height: 20),

                  // 2. Specialization Dropdown (Only for Providers)
                  if (widget.role == UserRole.Provider)
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
                      validator: (value) => value == null ? 'Specialization is required for providers.' : null,
                      hint: provider.isLoading ? const Text('Loading specialties...') : const Text('Select a category'),
                    ),
                  
                  if (widget.role == UserRole.Provider) const SizedBox(height: 30),

                  // 3. Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProfile,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Save Profile and Continue'),
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
