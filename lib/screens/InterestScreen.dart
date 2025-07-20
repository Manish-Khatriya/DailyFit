import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterestScreen extends StatefulWidget {
  @override
  _InterestScreenState createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final List<String> interests = [
    'Weight Loss',
    'Muscle Gain',
    'Cardio',
    'Yoga',
    'Endurance',
    'Flexibility',
    'Meditation',
    'Strength Training',
    'HIIT',
    'Diet Planning',
    'Zumba',
    'Pilates'
  ];

  final List<String> selectedInterests = [];

  // Save selected interests in SharedPreferences
  Future<void> saveInterestsToPrefs(List<String> interests) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_interests', interests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Step Indicator
            const Center(
              child: Text(
                "STEP 4/4",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "What Are Your Interests?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Select your goals and interests to\ncustomize your health journey.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Interests as chips
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: interests.map((interest) {
                    final isSelected = selectedInterests.contains(interest);
                    return ChoiceChip(
                      label: Text(interest),
                      selected: isSelected,
                      selectedColor: Colors.deepPurple,
                      backgroundColor: const Color(0xFFF0F0F0),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedInterests.add(interest);
                          } else {
                            selectedInterests.remove(interest);
                          }
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: selectedInterests.isNotEmpty
                    ? () async {
                  await saveInterestsToPrefs(selectedInterests);
                  Navigator.pushReplacementNamed(context, '/home');
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Finish", style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
