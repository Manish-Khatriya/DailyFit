import 'package:flutter/material.dart';
import 'package:DailyFit/services/app_data_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeightScreenmain extends StatefulWidget {
  const WeightScreenmain({super.key});

  @override
  State<WeightScreenmain> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreenmain> {
  final AppDataService _appDataService = AppDataService();
  List<WeightData> _weightHistory = [];
  UserGoals? _userGoals;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeightData();
  }

  Future<void> _fetchWeightData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _userGoals = await _appDataService.fetchUserGoals();
      _weightHistory = await _appDataService.fetchWeightHistory();
      debugPrint("Mock weight data fetched successfully!");
    } catch (e) {
      debugPrint("Error fetching mock weight data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WeightData? currentWeightData;
    WeightData? earliestWeightData;

    if (_weightHistory.isNotEmpty) {
      currentWeightData = _weightHistory.last;
      earliestWeightData = _weightHistory.first;
    }

    double currentWeight = currentWeightData?.weightKg ?? 0.0;
    int targetWeight = _userGoals?.targetWeightKg ?? 65;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Weight', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {

            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeightMetric("CURRENT", '${currentWeight.toStringAsFixed(1)} kg'),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.deepPurple, size: 30),
                ),
                _buildWeightMetric("TARGET", '${targetWeight.toStringAsFixed(0)} kg'),
              ],
            ),
            const SizedBox(height: 30),
            _weightHistory.isEmpty
                ? const Center(child: Text('No weight data available for chart.'))
                : SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = _weightHistory.length > value.toInt() && value.toInt() >= 0
                              ? _weightHistory[value.toInt()].date
                              : null;
                          if (date == null) return const Text('');
                          if (value.toInt() == 0 || value.toInt() == _weightHistory.length - 1 || value.toInt() % 2 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd MMM').format(date),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weightHistory.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.weightKg);
                      }).toList(),
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.deepPurple,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: _weightHistory.isEmpty ? 50 : _weightHistory.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) - 2,
                  maxY: _weightHistory.isEmpty ? 70 : _weightHistory.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b) + 2,
                  minX: 0,
                  maxX: (_weightHistory.length - 1).toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Timeline",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _weightHistory.isEmpty
                ? const Center(child: Text('No weight entries in timeline.'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weightHistory.length,
              itemBuilder: (context, index) {
                final weightEntry = _weightHistory[index];
                return _buildTimelineEntry(
                  weightEntry.weightKg,
                  weightEntry.date,
                  index == _weightHistory.length - 1,
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Add Weight button pressed!")),
                  );
                  _fetchWeightData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add Weight",
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

  Widget _buildWeightMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTimelineEntry(double weight, DateTime date, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.deepPurple.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat('dd MMM yyyy').format(date),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.deepPurple, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}