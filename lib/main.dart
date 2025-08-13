import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practical_1/Practicals/Practical_6/notes_app.dart';
import 'package:practical_1/Practicals/Practical_7/gallery_app.dart';
import 'package:practical_1/Practicals/Practical_7/product_catalog_app.dart';
import 'package:practical_1/Practicals/Practical_7/recipe_app.dart';

import 'practicals/Practical_4/form_validation_app.dart';
import 'practicals/practical_1/splashscreen.dart';
import 'practicals/practical_2/temperature_converter_screen.dart';
import 'practicals/practical_3/todo_app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final List<Map<String, dynamic>> practicals = [
    {
      'title': 'Splash Screen',
      'subtitle': 'App Launch & Branding',
      'widget': SplashScreen(),
      'icon': Icons.launch_rounded,
      'color': const Color(0xFF6C5CE7),
      'description': 'Interactive app introduction screen',
      'difficulty': 'Beginner',
      'duration': '5 min',
      'tag': 'UI/UX',
    },
    {
      'title': 'Temperature Converter',
      'subtitle': 'Unit Conversion System',
      'widget': TemperatureConverterScreen(),
      'icon': Icons.device_thermostat_rounded,
      'color': const Color(0xFFFF6B6B),
      'description': 'Real-time temperature calculations',
      'difficulty': 'Intermediate',
      'duration': '10 min',
      'tag': 'Logic',
    },
    {
      'title': 'TODO Application',
      'subtitle': 'Task Management System',
      'widget': TodoApp(),
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF4ECDC4),
      'description': 'Dynamic task organization tool',
      'difficulty': 'Advanced',
      'duration': '15 min',
      'tag': 'CRUD',
    },
    {
      'title': 'Form Validation',
      'subtitle': 'Registration & Feedback Forms',
      'widget': FormValidationApp(),
      'icon': Icons.assignment_rounded,
      'color': const Color(0xFF9B59B6),
      'description': 'Secure form input validation system',
      'difficulty': 'Intermediate',
      'duration': '12 min',
      'tag': 'Validation',
    },
    {
      'title': 'Notes Application',
      'subtitle': 'Note-taking & Storage',
      'widget': NotesApp(),
      'icon': Icons.note_rounded,
      'color': const Color(0xFF2ECC71),
      'description': 'Persistent note management system',
      'difficulty': 'Intermediate',
      'duration': '10 min',
      'tag': 'Storage',
    },
    {
      'title': 'Product Catalog',
      'subtitle': 'GridView & Custom Cards',
      'widget': ProductCatalogApp(),
      'icon': Icons.shopping_cart_rounded,
      'color': const Color(0xFFE74C3C),
      'description': 'Reusable widgets with grid layout',
      'difficulty': 'Advanced',
      'duration': '15 min',
      'tag': 'UI Design',
    },
    {
      'title': 'Recipe App',
      'subtitle': 'Recipe Management & Display',
      'icon': Icons.restaurant_menu_rounded,
      'color': const Color(0xFF3498DB),
      'description': 'Manage and display recipes with images',
      'difficulty': 'Intermediate',
      'widget': RecipeApp(), // This practical is a console app
      'duration': '15 min',
      'tag': 'UI Design',
    },
    {
      'title': 'Gallery App',
      'subtitle': 'Image Gallery with GridView',
      'icon': Icons.photo_library_rounded,
      'color': const Color(0xFFF1C40F),
      'description': 'Display images in a grid layout',
      'difficulty': 'Intermediate',
      'widget': GalleryApp(), // This practical is a console app
      'duration': '10 min',
      'tag': 'UI Design',
    }

  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Technical Practicals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      home: TechnicalLauncherScreen(practicals: practicals),
    );
  }
}

class TechnicalLauncherScreen extends StatelessWidget {
  final List<Map<String, dynamic>> practicals;

  const TechnicalLauncherScreen({super.key, required this.practicals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEV PRACTICALS'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: practicals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final practical = practicals[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: practical['color'].withOpacity(0.15),
                child: Icon(practical['icon'], color: practical['color']),
              ),
              title: Text(
                practical['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(practical['subtitle']),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                HapticFeedback.mediumImpact();
                if (practical['widget'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => practical['widget'],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Console App'),
                          content: const Text(
                            'This practical is a Dart console application.\n\nTo run it, use:\n\n dart lib/Practicals/CIE_1_2/online_course_platform.dart\n\nIt cannot be launched from the Flutter UI.',
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
              },
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About'),
            content: const Text(
              'Mobile App Development Practicals\nFlutter Framework\nVersion 1.0.0',
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
}
