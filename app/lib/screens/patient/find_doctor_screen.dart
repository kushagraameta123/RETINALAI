import 'package:flutter/material.dart';

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  final List<Map<String, dynamic>> _specialties = [
    {
      'name': 'Cardiology',
      'icon': Icons.favorite,
      'color': Colors.red,
      'doctors': 24,
    },
    {
      'name': 'Neurology',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'doctors': 18,
    },
    {
      'name': 'Dermatology',
      'icon': Icons.face,
      'color': Colors.orange,
      'doctors': 15,
    },
    {
      'name': 'Orthopedics',
      'icon': Icons.accessibility,
      'color': Colors.blue,
      'doctors': 22,
    },
    {
      'name': 'Pediatrics',
      'icon': Icons.child_care,
      'color': Colors.pink,
      'doctors': 20,
    },
    {
      'name': 'Dentistry',
      'icon': Icons.healing,
      'color': Colors.teal,
      'doctors': 16,
    },
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'Dr. lebabo',
      'specialty': 'Cardiologist',
      'rating': 4.9,
      'reviews': 128,
      'experience': '15 years',
      'education': 'MD, Harvard Medical School',
      'languages': ['English', 'Spanish'],
      'availability': 'Tomorrow',
      'image': 'assets/doctor1.jpg',
      'isOnline': true,
      'consultationFee': '\$150',
    },
    {
      'id': '2',
      'name': 'Dr. Michael Chen',
      'specialty': 'Neurologist',
      'rating': 4.8,
      'reviews': 95,
      'experience': '12 years',
      'education': 'MD, Johns Hopkins University',
      'languages': ['English', 'Mandarin'],
      'availability': 'Today',
      'image': 'assets/doctor2.jpg',
      'isOnline': true,
      'consultationFee': '\$180',
    },
    {
      'id': '3',
      'name': 'Dr. Emily Davis',
      'specialty': 'Dermatologist',
      'rating': 4.7,
      'reviews': 76,
      'experience': '10 years',
      'education': 'MD, Stanford University',
      'languages': ['English', 'French'],
      'availability': 'In 3 days',
      'image': 'assets/doctor3.jpg',
      'isOnline': false,
      'consultationFee': '\$120',
    },
    {
      'id': '4',
      'name': 'Dr. Robert Wilson',
      'specialty': 'Orthopedic Surgeon',
      'rating': 4.9,
      'reviews': 142,
      'experience': '18 years',
      'education': 'MD, Mayo Clinic',
      'languages': ['English'],
      'availability': 'Tomorrow',
      'image': 'assets/doctor4.jpg',
      'isOnline': true,
      'consultationFee': '\$200',
    },
  ];

  String _selectedSpecialty = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _doctors.where((doctor) {
      final matchesSpecialty = _selectedSpecialty == 'All' || 
          doctor['specialty'].toLowerCase().contains(_selectedSpecialty.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          doctor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor['specialty'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSpecialty && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors or specialties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Specialties Horizontal List
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _specialties.length + 1, // +1 for "All" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSpecialtyItem(
                    name: 'All',
                    icon: Icons.all_inclusive,
                    color: Colors.blue,
                    doctors: _doctors.length,
                    isSelected: _selectedSpecialty == 'All',
                  );
                }
                final specialty = _specialties[index - 1];
                return _buildSpecialtyItem(
                  name: specialty['name'],
                  icon: specialty['icon'],
                  color: specialty['color'],
                  doctors: specialty['doctors'],
                  isSelected: _selectedSpecialty == specialty['name'],
                );
              },
            ),
          ),

          // Doctors List Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Doctors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredDoctors.length} found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search criteria',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return _buildDoctorCard(doctor, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyItem({
    required String name,
    required IconData icon,
    required Color color,
    required int doctors,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSpecialty = name;
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$doctors doctors',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Doctor Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, size: 30, color: Colors.blue.shade700),
                    ),
                    if (doctor['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor['specialty'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            doctor['rating'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            ' (${doctor['reviews']} reviews)',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Consultation Fee
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      doctor['consultationFee'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'per consultation',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Info
            Row(
              children: [
                _buildInfoItem(Icons.work, doctor['experience']),
                _buildInfoItem(Icons.school, 'MD'),
                _buildInfoItem(Icons.language, '${doctor['languages'].length} languages'),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _viewDoctorProfile(doctor);
                    },
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text('Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _messageDoctor(doctor);
                    },
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _bookAppointment(doctor, context);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Book'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
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

  void _viewDoctorProfile(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildDoctorProfileSheet(doctor),
    );
  }

  Widget _buildDoctorProfileSheet(Map<String, dynamic> doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              doctor['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              doctor['specialty'],
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileItem('Experience', doctor['experience']),
          _buildProfileItem('Education', doctor['education']),
          _buildProfileItem('Languages', doctor['languages'].join(', ')),
          _buildProfileItem('Consultation Fee', doctor['consultationFee']),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookAppointment(doctor, context);
              },
              child: const Text('Book Appointment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _messageDoctor(Map<String, dynamic> doctor) {
    // TODO: Implement messaging
    Navigator.pushNamed(context, '/chat/${doctor['id']}');
  }

  void _bookAppointment(Map<String, dynamic> doctor, BuildContext context) {
    // TODO: Implement booking with pre-selected doctor
    Navigator.pushNamed(context, '/book-appointment');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking appointment with ${doctor['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
