import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:DailyFit/ThemeProvider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? gender;
  double? weight;
  double? height;
  List<String>? interests;
  double? bmi;
  String? bmiCategory;
  String? bmiAdvice;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gender = prefs.getString('gender') ?? 'Not selected';
      weight = prefs.getDouble('user_weight');
      height = prefs.getDouble('user_height');
      interests = prefs.getStringList('user_interests') ?? [];

      if (weight != null && height != null && height! > 0) {
        double heightInMeter = height! / 100;
        bmi = weight! / (heightInMeter * heightInMeter);
        _evaluateBMI(bmi!);
      }
    });
  }

  void _evaluateBMI(double bmi) {
    if (bmi < 18.5) {
      bmiCategory = "Underweight";
      bmiAdvice = "Eat more nutritious food, protein-rich diet & exercise.";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      bmiCategory = "Normal";
      bmiAdvice = "Great! Maintain your healthy lifestyle.";
    } else if (bmi >= 25 && bmi < 29.9) {
      bmiCategory = "Overweight";
      bmiAdvice = "Consider a healthy diet, regular walking, and exercise.";
    } else {
      bmiCategory = "Obese";
      bmiAdvice = "Consult a doctor, improve diet, and follow workout plan.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Your Profile', style: textTheme.headlineSmall!.copyWith(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            color: colorScheme.onPrimary,
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                backgroundColor: colorScheme.secondaryContainer,
                child: user?.photoURL == null
                    ? Icon(Icons.person, size: 50, color: colorScheme.onSecondaryContainer)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? 'No Name',
              style: textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No Email',
              style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Health Info", style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const Divider(height: 25, thickness: 1),
                  _infoRow(context, "Gender", gender ?? 'Not selected'),
                  _infoRow(context, "Weight", weight != null ? "${weight!.toStringAsFixed(1)} kg" : "Not set"),
                  _infoRow(context, "Height", height != null ? "${height!.toStringAsFixed(1)} cm" : "Not set"),
                  _infoRow(context, "Interests", interests != null && interests!.isNotEmpty
                      ? interests!.join(", ")
                      : "Not selected"),
                  if (bmi != null) ...[
                    const SizedBox(height: 10),
                    _infoRow(context, "BMI", "${bmi!.toStringAsFixed(2)} ($bmiCategory)"),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (bmiAdvice != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Health Suggestion:",
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "- $bmiAdvice",
                      style: textTheme.bodyMedium!.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  themeProvider.setSystemTheme();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Logout", style: textTheme.titleMedium!.copyWith(color: colorScheme.onError)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }
}