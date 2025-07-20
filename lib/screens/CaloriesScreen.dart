import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:DailyFit/services/app_data_service.dart';

class CaloriesScreen extends StatefulWidget {
  const CaloriesScreen({super.key});

  @override
  State<CaloriesScreen> createState() => _CaloriesScreenState();
}

class _CaloriesScreenState extends State<CaloriesScreen> with SingleTickerProviderStateMixin {
  final AppDataService _appDataService = AppDataService();

  int _dailyCalorieGoal = 2000;
  int _carbsGrams = 0;
  int _proteinGrams = 0;
  int _fatGrams = 0;
  bool _isLoading = true;

  int get carbsCalories => _carbsGrams * 4;
  int get proteinCalories => _proteinGrams * 4;
  int get fatCalories => _fatGrams * 9;
  int get consumedCalories => carbsCalories + proteinCalories + fatCalories;

  double get _targetCarbsProgressValue => (carbsCalories / _dailyCalorieGoal).clamp(0.0, 1.0);
  double get _targetProteinProgressValue => (proteinCalories / _dailyCalorieGoal).clamp(0.0, 1.0);
  double get _targetFatProgressValue => (fatCalories / _dailyCalorieGoal).clamp(0.0, 1.0);

  double get overallProgress => (consumedCalories / _dailyCalorieGoal).clamp(0.0, 1.0);

  double get _totalMacrosInGrams => (_carbsGrams + _proteinGrams + _fatGrams).toDouble();
  int get carbsPercentage => _totalMacrosInGrams > 0 ? ((_carbsGrams / _totalMacrosInGrams) * 100).round() : 0;
  int get proteinPercentage => _totalMacrosInGrams > 0 ? ((_proteinGrams / _totalMacrosInGrams) * 100).round() : 0;
  int get fatPercentage => _totalMacrosInGrams > 0 ? ((_fatGrams / _totalMacrosInGrams) * 100).round() : 0;

  late AnimationController _animationController;
  late Animation<double> _carbsAnimation;
  late Animation<double> _proteinAnimation;
  late Animation<double> _fatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchDailyMacroData();
  }

  Future<void> _fetchDailyMacroData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserGoals? goals = await _appDataService.fetchUserGoals();
      if (goals != null) {
        _dailyCalorieGoal = goals.dailyCalorieGoal;
      }

      Map<String, DailyMacroData> sevenDaysData = await _appDataService.fetchLastNDaysMacroData(7);
      String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      DailyMacroData? todayData = sevenDaysData[todayKey];

      if (todayData != null) {
        setState(() {
          _carbsGrams = todayData.carbsGrams;
          _proteinGrams = todayData.proteinGrams;
          _fatGrams = todayData.fatGrams;

          _carbsAnimation = Tween<double>(begin: 0.0, end: _targetCarbsProgressValue).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
          );
          _proteinAnimation = Tween<double>(begin: 0.0, end: _targetProteinProgressValue).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
          );
          _fatAnimation = Tween<double>(begin: 0.0, end: _targetFatProgressValue).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
          );

          _animationController.reset();
          _animationController.forward();
        });
      } else {
        setState(() {
          _carbsGrams = 0;
          _proteinGrams = 0;
          _fatGrams = 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching mock macro data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "DAILY INTAKE",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: "Today you have consumed "),
                    TextSpan(
                      text: "$consumedCalories",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    const TextSpan(text: " cal"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 250,
                height: 250,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          painter: _ConcentricRingProgressPainter(
                            carbsProgress: _carbsAnimation.value,
                            proteinProgress: _proteinAnimation.value,
                            fatProgress: _fatAnimation.value,
                            blueColor: const Color(0xFF4285F4),
                            purpleColor: const Color(0xFF9C27B0),
                            cyanColor: const Color(0xFF00BCD4),
                          ),
                          child: Container(),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${(overallProgress * 100).round()}%",
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "of daily goal",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMacroRow(const Color(0xFF4285F4), "Carbs", "${_carbsGrams}g", "${carbsPercentage}%"),
                    const Divider(height: 30, color: Colors.grey, thickness: 0.2),
                    _buildMacroRow(const Color(0xFF9C27B0), "Protein", "${_proteinGrams}g", "${proteinPercentage}%"),
                    const Divider(height: 30, color: Colors.grey, thickness: 0.2),
                    _buildMacroRow(const Color(0xFF00BCD4), "Fat", "${_fatGrams}g", "${fatPercentage}%"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _fetchDailyMacroData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Add Meal button pressed! Data refreshed.")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add Meal",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroRow(Color color, String type, String amount, String percentage) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Text(
          type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(width: 15),
        Text(
          percentage,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ConcentricRingProgressPainter extends CustomPainter {
  final double carbsProgress;
  final double proteinProgress;
  final double fatProgress;
  final Color blueColor;
  final Color purpleColor;
  final Color cyanColor;

  _ConcentricRingProgressPainter({
    required this.carbsProgress,
    required this.proteinProgress,
    required this.fatProgress,
    required this.blueColor,
    required this.purpleColor,
    required this.cyanColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;
    final double strokeWidth = 12.0;
    final double startAngle = -90 * (3.1415926535 / 180);
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double outerRingRadius = maxRadius - (strokeWidth / 2);
    final double middleRingRadius = outerRingRadius - strokeWidth - 8;
    final double innerRingRadius = middleRingRadius - strokeWidth - 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRingRadius),
      startAngle,
      360 * (3.1415926535 / 180),
      false,
      ringPaint..color = Colors.grey.shade200,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRingRadius),
      startAngle,
      360 * (3.1415926535 / 180),
      false,
      ringPaint..color = blueColor.withOpacity(0.2),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRingRadius),
      startAngle,
      carbsProgress * 360 * (3.1415926535 / 180),
      false,
      ringPaint..color = blueColor,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: middleRingRadius),
      startAngle,
      360 * (3.1415926535 / 180),
      false,
      ringPaint..color = purpleColor.withOpacity(0.2),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: middleRingRadius),
      startAngle,
      proteinProgress * 360 * (3.1415926535 / 180),
      false,
      ringPaint..color = purpleColor,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRingRadius),
      startAngle,
      360 * (3.1415926535 / 180),
      false,
      ringPaint..color = cyanColor.withOpacity(0.2),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRingRadius),
      startAngle,
      fatProgress * 360 * (3.1415926535 / 180),
      false,
      ringPaint..color = cyanColor,
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingProgressPainter oldDelegate) {
    return oldDelegate.carbsProgress != carbsProgress ||
        oldDelegate.proteinProgress != proteinProgress ||
        oldDelegate.fatProgress != fatProgress ||
        oldDelegate.blueColor != blueColor ||
        oldDelegate.purpleColor != purpleColor ||
        oldDelegate.cyanColor != cyanColor;
  }
}
