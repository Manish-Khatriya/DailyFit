import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderSelectionScreen extends StatefulWidget {
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                "STEP 1/4",
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              const SizedBox(height: 25),
              const Text(
                "Which one are you?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // Gender Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildGenderCard("Male", "assets/images/male.jpg"),
                  buildGenderCard("Female", "assets/images/female.jpg"),
                ],
              ),

              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "To give you a customized experience we need to know your gender",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 17),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: selectedGender != null
                    ? () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setString('gender', selectedGender!);
                  Navigator.pushNamed(context, '/weight');
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 80, vertical: 15),
                ),
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGenderCard(String gender, String imagePath) {
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        height: 210,
        decoration: BoxDecoration(
          color:
          isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
                color: Colors.deepPurple.shade100,
                blurRadius: 10,
                spreadRadius: 2)
          ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 140,
                width: 110,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.deepPurple : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
