import 'package:flutter/material.dart';

class DoctorApprovalScreen extends StatefulWidget {
  const DoctorApprovalScreen({super.key});

  @override
  State<DoctorApprovalScreen> createState() => _DoctorApprovalScreenState();
}

class _DoctorApprovalScreenState extends State<DoctorApprovalScreen> {
  final List<Map<String, dynamic>> _pendingDoctors = [
    {
      'id': '1',
      'name': 'Dr. James Wilson',
      'email': 'james.wilson@hospital.com',
      'specialty': 'Cardiology',
      'licenseNumber': 'MED123456',
      'experience': '8 years',
      'education': 'MD, Harvard Medical School',
      'submissionDate': '2024-01-15',
      'documents': ['Medical License', 'Board Certification', 'ID Proof'],
      'status': 'pending',
    },
    {
      'id': '2',
      'name': 'Dr. Maria Garcia',
      'email': 'maria.garcia@clinic.com',
      'specialty': 'Pediatrics',
      'licenseNumber': 'PED789012',
      'experience': '6 years',
      'education': 'MD, Stanford University',
      'submissionDate': '2024-01-14',
      'documents': ['Medical License', 'Residency Certificate'],
      'status': 'pending',
    },
    {
      'id': '3',
      'name': 'Dr. David Kim',
      'email': 'david.kim@medical.com',
      'specialty': 'Orthopedics',
      'licenseNumber': 'ORT345678',
      'experience': '12 years',
      'education': 'MD, Johns Hopkins University',
      'submissionDate': '2024-01-13',
      'documents': ['Medical License', 'Fellowship Certificate', 'Malpractice Insurance'],
      'status': 'pending',
    },
  ];

  final List<Map<String, dynamic>> _approvedDoctors = [
    {
      'id': '4',
      'name': 'Dr. Sarah Johnson',
      'email': 'sarah.johnson@hospital.com',
      'specialty': 'Cardiology',
      'licenseNumber': 'CAR901234',
      'approvalDate': '2024-01-10',
      'status': 'approved',
    },
    {
      'id': '5',
      'name': 'Dr. Michael Chen',
      'email': 'michael.chen@clinic.com',
      'specialty': 'Neurology',
      'licenseNumber': 'NEU567890',
      'approvalDate': '2024-01-08',
      'status': 'approved',
    },
  ];

  int _selectedTab = 0; // 0: Pending, 1: Approved

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Approvals'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
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
                    child: Text('Pending (${_pendingDoctors.length})'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 1 ? Colors.blue.shade50 : Colors.transparent,
                      foregroundColor: _selectedTab == 1 ? Colors.blue.shade700 : Colors.grey.shade600,
                    ),
                    child: Text('Approved (${_approvedDoctors.length})'),
                  ),
                ),
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: _selectedTab == 0
                ? _buildPendingDoctorsList()
                : _buildApprovedDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingDoctorsList() {
    if (_pendingDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No pending approvals',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _pendingDoctors[index];
        return _buildPendingDoctorCard(doctor);
      },
    );
  }

  Widget _buildApprovedDoctorsList() {
    if (_approvedDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No approved doctors',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _approvedDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _approvedDoctors[index];
        return _buildApprovedDoctorCard(doctor);
      },
    );
  }

  Widget _buildPendingDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Header
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
                        doctor['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor['specialty'],
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Doctor Details
            _buildDetailRow('Email', doctor['email']),
            _buildDetailRow('License', doctor['licenseNumber']),
            _buildDetailRow('Experience', doctor['experience']),
            _buildDetailRow('Education', doctor['education']),
            _buildDetailRow('Submitted', doctor['submissionDate']),

            const SizedBox(height: 12),

            // Documents
            const Text(
              'Submitted Documents:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: doctor['documents'].map<Widget>((doc) => Chip(
                label: Text(doc),
                backgroundColor: Colors.blue.shade50,
                labelStyle: const TextStyle(fontSize: 12),
              )).toList(),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _viewDoctorDocuments(doctor);
                    },
                    icon: const Icon(Icons.folder_open, size: 16),
                    label: const Text('View Documents'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _approveDoctor(doctor);
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _rejectDoctor(doctor);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.person, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
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
                      Text(
                        doctor['specialty'],
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'APPROVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildDetailRow('Email', doctor['email']),
            _buildDetailRow('License', doctor['licenseNumber']),
            _buildDetailRow('Approved On', doctor['approvalDate']),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewDoctorProfile(doctor);
                    },
                    child: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _revokeApproval(doctor);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Revoke'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewDoctorDocuments(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Documents - ${doctor['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Submitted documents:'),
              const SizedBox(height: 8),
              ...doctor['documents'].map<Widget>((doc) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(doc),
                  ],
                ),
              )).toList(),
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

  void _approveDoctor(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Doctor?'),
        content: Text('Are you sure you want to approve ${doctor['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingDoctors.remove(doctor);
                _approvedDoctors.add({
                  ...doctor,
                  'status': 'approved',
                  'approvalDate': '2024-01-${DateTime.now().day}',
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Doctor ${doctor['name']} approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectDoctor(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application?'),
        content: Text('Are you sure you want to reject ${doctor['name']}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingDoctors.remove(doctor);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Doctor application rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewDoctorProfile(Map<String, dynamic> doctor) {
    // TODO: Implement doctor profile view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Doctor Profile'),
        content: Text('Profile view for ${doctor['name']} will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _revokeApproval(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Approval?'),
        content: Text('Are you sure you want to revoke ${doctor['name']}\'s approval?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _approvedDoctors.remove(doctor);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Doctor approval revoked'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}
