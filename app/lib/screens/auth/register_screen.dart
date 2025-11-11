import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:healthcare_app/providers/auth_provider.dart';
import 'package:healthcare_app/widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _hospitalClinicController = TextEditingController();
  
  String _selectedAccountType = 'Patient';
  String? _selectedSpecialty;
  String? _selectedDepartment;

  final List<String> _specialties = ['Ophthalmology', 'Cardiology', 'Neurology'];
  final List<String> _departments = ['Retinal Diseases', 'Glaucoma Care', 'Emergency Eye Care'];

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Split full name into first and last
      final nameParts = _fullNameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';


      final Map<String, dynamic> profileData = {
        'role': _selectedAccountType.toLowerCase(),
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': _phoneController.text,
        'dateOfBirth': _dobController.text,
        'specialization': _selectedSpecialty,
        'department': _selectedDepartment,
        'yearsOfExperience': int.tryParse(_yearsOfExperienceController.text) ?? 0,
        'licenseNumber': _licenseNumberController.text,
        'hospitalClinic': _hospitalClinicController.text,
      };

      final result = await authProvider.register(
        _emailController.text,
        _passwordController.text,
        profileData,
      );
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Check your email to verify.')),
        );
        // Use pushReplacement to clear the registration from stack
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Join the Retinal-AI platform',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    validator: (value) => value!.isEmpty ? 'Enter full name' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => !RegExp(r'\S+@\S+\.\S+').hasMatch(value!) ? 'Enter valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    initialValue: _selectedAccountType,
                    items: ['Patient', 'Doctor'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAccountType = newValue!;
                      });
                    },
                  ),
                  if (_selectedAccountType == 'Doctor') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Medical Specialty',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            initialValue: _selectedSpecialty,
                            items: _specialties.map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSpecialty = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            initialValue: _selectedDepartment,
                            items: _departments.map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDepartment = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _yearsOfExperienceController,
                      labelText: 'Years of Experience',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _licenseNumberController,
                            labelText: 'License Number',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _hospitalClinicController,
                            labelText: 'Hospital/Clinic',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _dobController,
                    labelText: 'Date of Birth (dd/mm/yyyy)',
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    isPassword: true,
                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    isPassword: true,
                    validator: (value) => value!.isEmpty ? 'Confirm password' : null,
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return ElevatedButton.icon(
                        onPressed: auth.isLoading ? null : _register,
                        icon: auth.isLoading ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ) : const Icon(Icons.person_add),
                        label: const Text('Create Account'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Already have an account? Sign in here'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('← Back to home'),
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
