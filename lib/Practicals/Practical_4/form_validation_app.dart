import 'package:flutter/material.dart';

import 'advanced_registration_form.dart';
import 'enhanced_feedback_form.dart';
import 'feedback_form.dart';
import 'registration_app.dart';

class FormValidationApp extends StatelessWidget {
  const FormValidationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Validation Demo'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade100, Colors.indigo.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.assignment, size: 60, color: Colors.indigo),
                  SizedBox(height: 16),
                  Text(
                    'Form Validation Examples',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore advanced form validation techniques and UI patterns',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Key Features Section
            const Text(
              'Key Features Demonstrated:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureCard(
              icon: Icons.check_circle_outline,
              title: 'Advanced Form Validation',
              description:
                  'Real-time validation with strength indicators and visual feedback',
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.control_camera,
              title: 'Controllers & Keys',
              description:
                  'TextEditingController, GlobalKey, and form state management',
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.security,
              title: 'Input Security',
              description:
                  'Password strength, email validation, and secure input handling',
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.star_rate,
              title: 'Interactive Rating System',
              description:
                  'Animated sliders, star ratings, and haptic feedback',
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.timeline,
              title: 'Multi-step Forms',
              description:
                  'Step-by-step forms with progress indicators and validation',
            ),
            const SizedBox(height: 32),

            // Form Options
            const Text(
              'Choose a Form to Explore:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            // Registration Form Button
            _buildFormButton(
              context: context,
              title: 'Registration Form',
              subtitle: 'Complete user registration with validation',
              icon: Icons.person_add,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationApp(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Advanced Registration Form Button
            _buildFormButton(
              context: context,
              title: 'Advanced Registration',
              subtitle: 'Multi-step registration with enhanced validation',
              icon: Icons.app_registration,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdvancedRegistrationForm(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Feedback Form Button
            _buildFormButton(
              context: context,
              title: 'Feedback Form',
              subtitle: 'Rating system with feedback collection',
              icon: Icons.feedback,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackForm()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Enhanced Feedback Form Button
            _buildFormButton(
              context: context,
              title: 'Enhanced Feedback',
              subtitle: 'Advanced feedback with animated ratings',
              icon: Icons.rate_review,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedFeedbackForm(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32), // Add extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.indigo, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
