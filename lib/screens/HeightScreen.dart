import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeightScreen extends StatefulWidget {
  @override
  _HeightScreenState createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  double selectedHeight = 170;
  bool isTouched = false;

  // Save height using SharedPreferences
  Future<void> saveHeightToPrefs(double height) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_height', height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Step Indicator
            const Text(
              "STEP 3/4",
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),

            const SizedBox(height: 25),

            const Text(
              "What’s Your Height?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Height in cm — you can update this later too.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Height Picker
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    selectedHeight.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'centimeters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: selectedHeight,
                    min: 20,
                    max: 250,
                    divisions: 230,
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      setState(() {
                        selectedHeight = value;
                        isTouched = true;
                      });
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: isTouched
                  ? () async {
                await saveHeightToPrefs(selectedHeight);
                Navigator.pushNamed(context, '/interest');
              }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
