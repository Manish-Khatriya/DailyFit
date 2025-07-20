import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/step_data_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class StepSummaryScreen extends StatefulWidget {
  const StepSummaryScreen({super.key});

  @override
  State<StepSummaryScreen> createState() => _StepSummaryScreenState();
}

class _StepSummaryScreenState extends State<StepSummaryScreen> {
  List<StepData> weeklySteps = [];
  bool isLoading = true;
  int totalSteps = 0;
  final int goal = 16000;

  @override
  void initState() {
    super.initState();
    fetchSteps();
  }

  Future<void> fetchSteps() async {
    try {
      final data = await ApiService.fetchWeeklySteps();
      setState(() {
        weeklySteps = data;
        totalSteps = data.isNotEmpty ? data.last.count : 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  double get progress => (totalSteps / goal).clamp(0.0, 1.0);
  double get distance => (totalSteps * 0.0008);
  double get calories => (totalSteps * 0.04);
  double get time => (totalSteps / 130);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "DAILY STEPS",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You've completed ${(progress * 100).round()}% of your step goal!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(seconds: 1),
                builder: (context, value, _) {
                  return SizedBox(
                    height: 180,
                    width: 180,
                    child: CustomPaint(
                      painter: GradientCircularProgressPainter(value),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_walk, size: 30, color: Colors.deepPurple),
                            const SizedBox(height: 6),
                            Text(
                              "$totalSteps",
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const Text("steps", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedInfoTile(
                    icon: Icons.local_fire_department,
                    label: 'kcal',
                    value: calories,
                    maxValue: 500,
                    color: Colors.orange,
                  ),
                  AnimatedInfoTile(
                    icon: Icons.location_on,
                    label: 'km',
                    value: distance,
                    maxValue: 10,
                    color: Colors.blueAccent,
                  ),
                  AnimatedInfoTile(
                    icon: Icons.timer,
                    label: 'min',
                    value: time,
                    maxValue: 120,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        TabButton(title: "WEEK", isActive: true, buttonColor: Color(0xFF4A8989)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          minX: 0,
                          maxX: 6,
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.3),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.3),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      days[value.toInt() % 7],
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: weeklySteps.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.count / 1000);
                              }).toList(),
                              isCurved: true,
                              color: Colors.white,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFF9F2B68),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              barWidth: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}