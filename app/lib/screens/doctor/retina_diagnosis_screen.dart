import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RetinaDiagnosisScreen extends StatefulWidget {
  const RetinaDiagnosisScreen({super.key});

  @override
  State<RetinaDiagnosisScreen> createState() => _RetinaDiagnosisScreenState();
}

class _RetinaDiagnosisScreenState extends State<RetinaDiagnosisScreen> {
  Uint8List? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _diagnosisResult;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = bytes;
          _diagnosisResult = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isAnalyzing = false;
      _diagnosisResult = {
        'condition': 'Diabetic Retinopathy',
        'confidence': '92%',
        'severity': 'Moderate',
        'recommendations': [
          'Consult with an ophthalmologist within 2 weeks',
          'Monitor blood sugar levels regularly',
          'Schedule follow-up appointment in 3 months',
        ],
        'description': 'The analysis shows signs of microaneurysms and hemorrhages consistent with moderate diabetic retinopathy. Early intervention is recommended.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retina Diagnosis'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Retina Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload a clear image of the retina for AI-powered analysis. '
                      'Our system can detect various conditions including diabetic retinopathy, '
                      'glaucoma, and macular degeneration.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Image Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Retina Image',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_selectedImage == null)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('No image selected', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.memory(_selectedImage!, fit: BoxFit.cover),
                      ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('From Gallery'),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeImage,
                          icon: _isAnalyzing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.analytics),
                          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Image'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Results Section
            if (_diagnosisResult != null) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Analysis Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Condition and Confidence
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildResultItem('Condition', _diagnosisResult!['condition']),
                            _buildResultItem('Confidence', _diagnosisResult!['confidence']),
                            _buildResultItem('Severity', _diagnosisResult!['severity']),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        _diagnosisResult!['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Recommendations
                      const Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._diagnosisResult!['recommendations'].map<Widget>((recommendation) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(recommendation)),
                          ],
                        ),
                      )).toList(),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Save report
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Save Report'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Share with doctor
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share with Doctor'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Loading Indicator
            if (_isAnalyzing) ...[
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing retina image...'),
                  ],
                ),
              ),
            ],

            // Tips Section
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tips for Best Results:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTip('Use good lighting when taking the photo'),
                    _buildTip('Ensure the retina is clearly visible'),
                    _buildTip('Avoid blurry or out-of-focus images'),
                    _buildTip('Take multiple shots from different angles'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
