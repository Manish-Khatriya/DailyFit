import 'package:flutter/material.dart';
import 'package:DailyFit/services/app_data_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppDataService _appDataService = AppDataService();
  UserGoals? _userGoals;
  Map<String, DailyHealthSummaryData> _dailyHealthSummary = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _userGoals = await _appDataService.fetchUserGoals();
      _dailyHealthSummary = await _appDataService.fetchLastNDaysHealthSummary(7);
      debugPrint("Mock health summary data fetched successfully!");
    } catch (e) {
      debugPrint("Error fetching mock health data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DailyHealthSummaryData? todaySummary = _dailyHealthSummary[todayKey];
    int todaySteps = todaySummary?.steps ?? 0;
    double todayCaloriesBurned = todaySummary?.caloriesBurned ?? 0.0;
    double todayWaterIntake = todaySummary?.waterIntake ?? 0.0;

    int dailyStepGoal = _userGoals?.dailyStepGoal ?? 10000;
    double dailyWaterGoalLitres = _userGoals?.dailyWaterGoalLitres ?? 2.5;

    double stepsProgress = (todaySteps / dailyStepGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Health Tracker (Mock JSON)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchHealthData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DAILY STEPS",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You've completed ${(stepsProgress * 100).round()}% of your step goal!",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: stepsProgress,
                      strokeWidth: 15,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_walk, size: 30, color: Colors.deepPurple),
                        Text(
                          "$todaySteps",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "steps",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCircle(Colors.orange, Icons.local_fire_department, '${todayCaloriesBurned.toStringAsFixed(0)} kcal'),
                _buildMetricCircle(Colors.blue, Icons.location_on, '${(todaySteps * 0.00076).toStringAsFixed(1)} km'),
                _buildMetricCircle(Colors.green, Icons.timer, '78 min'),
              ],
            ),
            const SizedBox(height: 30),
            Text('Steps Trend (Last 7 Days):', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Mon'; break;
                            case 1: text = 'Tue'; break;
                            case 2: text = 'Wed'; break;
                            case 3: text = 'Thu'; break;
                            case 4: text = 'Fri'; break;
                            case 5: text = 'Sat'; break;
                            case 6: text = 'Sun'; break;
                            default: text = ''; break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _dailyHealthSummary.entries.toList().asMap().entries.map((entry) {
                        int index = entry.key;
                        DailyHealthSummaryData data = entry.value.value;
                        return FlSpot(index.toDouble(), data.steps.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "HYDRATION",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Today you took ${todayWaterIntake * 1000} ml of water",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            Text(
              "Almost there! Keep hydrated",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (todayWaterIntake / dailyWaterGoalLitres).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWaterButton(Icons.remove, () {
                  setState(() {
                    if (todaySummary != null) {
                      _dailyHealthSummary[todayKey] = DailyHealthSummaryData(
                        date: todaySummary.date,
                        steps: todaySummary.steps,
                        caloriesBurned: todaySummary.caloriesBurned,
                        waterIntake: (todaySummary.waterIntake - 0.25).clamp(0.0, dailyWaterGoalLitres),
                      );
                    }
                  });
                }),
                _buildWaterGlassIndicator('1x Glass\n200 ml'),
                _buildWaterButton(Icons.add, () {
                  setState(() {
                    if (todaySummary != null) {
                      _dailyHealthSummary[todayKey] = DailyHealthSummaryData(
                        date: todaySummary.date,
                        steps: todaySummary.steps,
                        caloriesBurned: todaySummary.caloriesBurned,
                        waterIntake: (todaySummary.waterIntake + 0.25).clamp(0.0, dailyWaterGoalLitres),
                      );
                    }
                  });
                }),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Add Drink button pressed! Data refreshed.")),
                  );
                  _fetchHealthData();
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCircle(Color color, IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.deepPurple, size: 30),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildWaterGlassIndicator(String text) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop, color: Colors.white, size: 35),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

extension IterableIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}