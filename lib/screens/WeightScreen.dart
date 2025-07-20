import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightScreen extends StatefulWidget {
  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double selectedWeight = 70;
  bool isTouched = false;

  Future<void> saveWeightToPrefs(double weight) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', weight);
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
            const Text(
              "STEP 2/4",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "What’s Your Weight?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Weight in kg — don’t worry,\nyou can always change it later.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    selectedWeight.toInt().toString(),
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
                      'kilograms',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: selectedWeight,
                    min: 10,
                    max: 150,
                    divisions: 140,
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      setState(() {
                        selectedWeight = value;
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
                await saveWeightToPrefs(selectedWeight);
                Navigator.pushNamed(context, '/height');
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