import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedFeedbackForm extends StatefulWidget {
  const EnhancedFeedbackForm({super.key});

  @override
  State<EnhancedFeedbackForm> createState() => _EnhancedFeedbackFormState();
}

class _EnhancedFeedbackFormState extends State<EnhancedFeedbackForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late AnimationController _starAnimationController;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();

  // Rating variables
  double _overallRating = 3.0;
  double _serviceRating = 3.0;
  double _qualityRating = 3.0;
  double _valueRating = 3.0;
  double _supportRating = 3.0;

  // Form state
  String? _feedbackCategory;
  String? _priorityLevel;
  bool _recommendToOthers = false;
  bool _allowContact = true;
  bool _isAnonymous = false;
  bool _isLoading = false;

  // Validation
  bool _isEmailValid = false;

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Complaint',
    'Compliment',
    'Suggestion',
    'Technical Support',
    'User Experience',
    'Performance Issue',
    'Other',
  ];

  final List<String> _priorityLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _isEmailValid = false);
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      setState(() => _isEmailValid = false);
      return 'Please enter a valid email address';
    }
    setState(() => _isEmailValid = true);
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters long';
    }
    if (value.trim().length > 1000) {
      return 'Message must be less than 1000 characters';
    }
    return null;
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.orange[700], size: 20),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey[700]),
            hintStyle: TextStyle(color: Colors.grey[500]),
            counterStyle: TextStyle(color: Colors.grey[600]),
          ),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.orange[700], size: 20),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey[700]),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required String subtitle,
    required double rating,
    required ValueChanged<double> onRatingChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.orange[700], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Slider(
                  value: rating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 4,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.grey[300],
                  onChanged: (value) {
                    onRatingChanged(value);
                    HapticFeedback.lightImpact();
                    _starAnimationController.forward().then((_) {
                      _starAnimationController.reverse();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              _buildStarRating(rating),
            ],
          ),
          Center(
            child: Text(
              _getRatingText(rating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(rating),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: _starAnimationController,
          curve: Curves.elasticOut,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < rating.floor()
                ? Icons.star
                : index < rating
                ? Icons.star_half
                : Icons.star_border,
            color: Colors.amber,
            size: 24,
          );
        }),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 1.5) return 'Very Poor';
    if (rating <= 2.5) return 'Poor';
    if (rating <= 3.5) return 'Average';
    if (rating <= 4.5) return 'Good';
    return 'Excellent';
  }

  Color _getRatingColor(double rating) {
    if (rating <= 2.0) return Colors.red;
    if (rating <= 3.0) return Colors.orange;
    if (rating <= 4.0) return Colors.blue;
    return Colors.green;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange[700], size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_feedbackCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a feedback category'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Feedback Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thank you for your valuable feedback!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'We appreciate your time and will review your feedback carefully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feedback Summary:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Name',
                        _isAnonymous ? 'Anonymous' : _nameController.text,
                      ),
                      _buildSummaryRow('Category', _feedbackCategory ?? ''),
                      _buildSummaryRow('Priority', _priorityLevel ?? 'Medium'),
                      _buildSummaryRow(
                        'Overall Rating',
                        '${_overallRating.toInt()}/5 stars',
                      ),
                      _buildSummaryRow(
                        'Recommend',
                        _recommendToOthers ? 'Yes' : 'No',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetForm();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('New Feedback'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
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
    _phoneController.clear();
    setState(() {
      _overallRating = 3.0;
      _serviceRating = 3.0;
      _qualityRating = 3.0;
      _valueRating = 3.0;
      _supportRating = 3.0;
      _feedbackCategory = null;
      _priorityLevel = null;
      _recommendToOthers = false;
      _allowContact = true;
      _isAnonymous = false;
      _isEmailValid = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Enhanced Feedback Form'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Reset Form'),
                      content: const Text(
                        'Are you sure you want to reset all fields?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetForm();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.orange[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.feedback, size: 60, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'We Value Your Feedback',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Help us improve by sharing your thoughts and experiences',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Contact Information
              _buildSectionHeader('Contact Information', Icons.person),

              CheckboxListTile(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                title: const Text('Submit feedback anonymously'),
                subtitle: const Text(
                  'Your personal information will not be shared',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.orange,
              ),
              const SizedBox(height: 16),

              if (!_isAnonymous) ...[
                _buildAnimatedTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person,
                  validator: _validateName,
                ),
                _buildAnimatedTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  icon: Icons.email,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  suffixIcon:
                      _isEmailValid
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
                _buildAnimatedTextField(
                  controller: _phoneController,
                  label: 'Phone Number (Optional)',
                  hint: 'Enter your phone number',
                  icon: Icons.phone,
                  validator: (value) => null, // Optional field
                  keyboardType: TextInputType.phone,
                ),
              ],

              // Feedback Details
              _buildSectionHeader('Feedback Details', Icons.assignment),

              _buildAnimatedDropdown(
                label: 'Feedback Category',
                value: _feedbackCategory,
                items: _categories,
                onChanged: (value) {
                  setState(() {
                    _feedbackCategory = value;
                  });
                },
                icon: Icons.category,
              ),

              _buildAnimatedDropdown(
                label: 'Priority Level',
                value: _priorityLevel,
                items: _priorityLevels,
                onChanged: (value) {
                  setState(() {
                    _priorityLevel = value;
                  });
                },
                icon: Icons.flag,
              ),

              _buildAnimatedTextField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'Brief summary of your feedback',
                icon: Icons.subject,
                validator: (value) => _validateRequired(value, 'Subject'),
              ),

              _buildAnimatedTextField(
                controller: _messageController,
                label: 'Message',
                hint: 'Please describe your feedback in detail...',
                icon: Icons.message,
                validator: _validateMessage,
                maxLines: 5,
                maxLength: 1000,
              ),

              // Rating Section
              _buildSectionHeader('Rate Your Experience', Icons.star),

              _buildRatingSection(
                title: 'Overall Experience',
                subtitle: 'How would you rate your overall experience?',
                rating: _overallRating,
                onRatingChanged: (value) {
                  setState(() {
                    _overallRating = value;
                  });
                },
                icon: Icons.sentiment_satisfied,
              ),

              _buildRatingSection(
                title: 'Service Quality',
                subtitle: 'Rate the quality of service provided',
                rating: _serviceRating,
                onRatingChanged: (value) {
                  setState(() {
                    _serviceRating = value;
                  });
                },
                icon: Icons.room_service,
              ),

              _buildRatingSection(
                title: 'Product/Feature Quality',
                subtitle: 'Rate the quality of our product/features',
                rating: _qualityRating,
                onRatingChanged: (value) {
                  setState(() {
                    _qualityRating = value;
                  });
                },
                icon: Icons.high_quality,
              ),

              _buildRatingSection(
                title: 'Value for Money',
                subtitle: 'Rate the value you received',
                rating: _valueRating,
                onRatingChanged: (value) {
                  setState(() {
                    _valueRating = value;
                  });
                },
                icon: Icons.attach_money,
              ),

              _buildRatingSection(
                title: 'Customer Support',
                subtitle: 'Rate our customer support service',
                rating: _supportRating,
                onRatingChanged: (value) {
                  setState(() {
                    _supportRating = value;
                  });
                },
                icon: Icons.support_agent,
              ),

              // Additional Options
              _buildSectionHeader('Additional Options', Icons.tune),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _recommendToOthers,
                      onChanged: (value) {
                        setState(() {
                          _recommendToOthers = value;
                        });
                        HapticFeedback.lightImpact();
                      },
                      title: const Text('Would you recommend us to others?'),
                      subtitle: const Text(
                        'Help us understand your satisfaction level',
                      ),
                      activeColor: Colors.orange,
                    ),
                    if (!_isAnonymous)
                      SwitchListTile(
                        value: _allowContact,
                        onChanged: (value) {
                          setState(() {
                            _allowContact = value;
                          });
                          HapticFeedback.lightImpact();
                        },
                        title: const Text('Allow us to contact you'),
                        subtitle: const Text(
                          'We may reach out for follow-up questions',
                        ),
                        activeColor: Colors.orange,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Container(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitFeedback,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Submitting...' : 'Submit Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
