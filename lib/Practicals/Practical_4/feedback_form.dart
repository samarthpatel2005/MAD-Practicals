import 'package:flutter/material.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  double _overallRating = 3.0;
  double _serviceRating = 3.0;
  double _qualityRating = 3.0;
  String? _feedbackCategory;
  bool _recommendToOthers = false;

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Complaint',
    'Compliment',
    'Suggestion',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      if (_feedbackCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a feedback category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.thumb_up, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Feedback Submitted!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thank you for your valuable feedback!'),
              const SizedBox(height: 15),
              _buildInfoRow('Name', _nameController.text),
              _buildInfoRow('Category', _feedbackCategory!),
              _buildInfoRow(
                'Overall Rating',
                '${_overallRating.toInt()}/5 stars',
              ),
              _buildInfoRow(
                'Service Rating',
                '${_serviceRating.toInt()}/5 stars',
              ),
              _buildInfoRow(
                'Quality Rating',
                '${_qualityRating.toInt()}/5 stars',
              ),
              _buildInfoRow('Recommend', _recommendToOthers ? 'Yes' : 'No'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _overallRating = 3.0;
      _serviceRating = 3.0;
      _qualityRating = 3.0;
      _feedbackCategory = null;
      _recommendToOthers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.orange.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.feedback, size: 50, color: Colors.orange),
                    SizedBox(height: 10),
                    Text(
                      'We Value Your Feedback',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Help us improve our services',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Full Name', Icons.person),
                validator: (value) => _validateRequired(value, 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email Address', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 24),

              // Feedback Category
              _buildSectionHeader('Feedback Details'),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _feedbackCategory,
                decoration: _buildInputDecoration(
                  'Feedback Category',
                  Icons.category,
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _feedbackCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a feedback category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _subjectController,
                decoration: _buildInputDecoration('Subject', Icons.subject),
                validator: (value) => _validateRequired(value, 'Subject'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _messageController,
                decoration: _buildInputDecoration(
                  'Your Message',
                  Icons.message,
                ).copyWith(alignLabelWithHint: true),
                maxLines: 4,
                validator: (value) => _validateRequired(value, 'Message'),
              ),
              const SizedBox(height: 24),

              // Rating Section
              _buildSectionHeader('Rate Your Experience'),
              const SizedBox(height: 16),

              _buildRatingSection('Overall Experience', _overallRating, (
                value,
              ) {
                setState(() {
                  _overallRating = value;
                });
              }),
              const SizedBox(height: 16),

              _buildRatingSection('Service Quality', _serviceRating, (value) {
                setState(() {
                  _serviceRating = value;
                });
              }),
              const SizedBox(height: 16),

              _buildRatingSection('Product Quality', _qualityRating, (value) {
                setState(() {
                  _qualityRating = value;
                });
              }),
              const SizedBox(height: 24),

              // Recommendation
              _buildSectionHeader('Recommendation'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _recommendToOthers,
                    onChanged: (bool? value) {
                      setState(() {
                        _recommendToOthers = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Would you recommend our services to others?',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Reset Button
              OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Reset Form', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildRatingSection(
    String title,
    double rating,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: rating,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: '${rating.toInt()} stars',
                onChanged: onChanged,
                activeColor: Colors.orange,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${rating.toInt()}/5',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
