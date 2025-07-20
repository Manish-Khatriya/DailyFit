import 'package:flutter/material.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  int waterConsumedMl = 750;
  final int dailyWaterGoalMl = 2000;

  double get waterProgress => (waterConsumedMl / dailyWaterGoalMl).clamp(0.0, 1.0);

  void _addWater(int ml) {
    setState(() {
      waterConsumedMl = (waterConsumedMl + ml).clamp(0, dailyWaterGoalMl);
    });
  }

  void _subtractWater(int ml) {
    setState(() {
      waterConsumedMl = (waterConsumedMl - ml).clamp(0, dailyWaterGoalMl);
    });
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "HYDRATION",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: "Today you took "),
                    TextSpan(
                      text: "$waterConsumedMl ml",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple
                      ),
                    ),
                    const TextSpan(text: " of water"),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Almost there! Keep hydrated",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: waterProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade300,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: waterProgress * (MediaQuery.of(context).size.width - 2 * 20 - 40),
                    child: Transform.translate(
                      offset: const Offset(0, -40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "$waterConsumedMl",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWaterLevelMarker("Poor"),
                  _buildWaterLevelMarker("Good"),
                  _buildWaterLevelMarker("Almost"),
                  _buildWaterLevelMarker("Perfect"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(20, (index) => Container(
                  width: 2,
                  height: 10,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                )),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWaterActionButton(Icons.remove, () => _subtractWater(200)),
                        const SizedBox(width: 20),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_drink_rounded, color: Colors.cyan.shade300, size: 35),
                              const Text("1x Glass", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const Text("200 ml", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        _buildWaterActionButton(Icons.add, () => _addWater(200)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Add Drink button pressed! Water: $waterConsumedMl ml")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Add Drink",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterLevelMarker(String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWaterActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.deepPurple, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}