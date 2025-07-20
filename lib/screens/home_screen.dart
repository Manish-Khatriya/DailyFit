import 'package:DailyFit/screens/CaloriesScreen.dart';
import 'package:DailyFit/screens/WeightScreenmain.dart';
import 'package:DailyFit/screens/user_profile_screen.dart';
import 'package:DailyFit/services/app_data_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DailyFit/screens/WaterScreen.dart';
import 'package:DailyFit/screens/graph_screen.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDataService _appDataService = AppDataService();
  UserGoals? _userGoals;
  Map<String, DailyHealthSummaryData> _dailyHealthSummary = {};
  Map<String, DailyMacroData> _dailyMacroDetails = {};
  List<WeightData> _weightHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomePageData();
  }

  Future<void> _fetchHomePageData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _userGoals = await _appDataService.fetchUserGoals();
      _dailyHealthSummary = await _appDataService.fetchLastNDaysHealthSummary(7);
      _dailyMacroDetails = await _appDataService.fetchLastNDaysMacroData(7);
      _weightHistory = await _appDataService.fetchWeightHistory();
      debugPrint("Home page mock data fetched successfully!");
    } catch (e) {
      debugPrint("Error fetching home page mock data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DailyHealthSummaryData? todaySummary = _dailyHealthSummary[todayKey];
    DailyMacroData? todayMacros = _dailyMacroDetails[todayKey];
    WeightData? currentWeightData = _weightHistory.isNotEmpty ? _weightHistory.last : null;

    int todaySteps = todaySummary?.steps ?? 0;
    double todayCaloriesBurned = todaySummary?.caloriesBurned ?? 0.0;
    double todayWaterIntake = todaySummary?.waterIntake ?? 0.0;
    double currentWeight = currentWeightData?.weightKg ?? 0.0;
    int totalMacrosCalories = todayMacros?.totalCalories ?? 0;

    int dailyStepGoal = _userGoals?.dailyStepGoal ?? 10000;
    int dailyCalorieGoal = _userGoals?.dailyCalorieGoal ?? 2000;
    double dailyWaterGoalLitres = _userGoals?.dailyWaterGoalLitres ?? 2.5;

    double stepsProgress = (todaySteps / dailyStepGoal).clamp(0.0, 1.0);
    double caloriesProgress = (totalMacrosCalories / dailyCalorieGoal).clamp(0.0, 1.0);
    double waterProgress = (todayWaterIntake / dailyWaterGoalLitres).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      backgroundColor: colorScheme.primaryContainer,
                      radius: 24,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, color: colorScheme.onPrimaryContainer)
                          : null,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEE dd MMM').format(DateTime.now()).toUpperCase(),
                        style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Hi, ${user?.displayName ?? 'User'}',
                style: textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '72',
                              style: textTheme.headlineLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health Score', style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          Text(
                            'Based on your overall health test, your score is 84 and consider good',
                            style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Read more',
                            style: textTheme.bodyMedium!.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Metrics', style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  Icon(Icons.more_horiz, color: colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCaloriesCard(context, totalMacrosCalories, caloriesProgress),
                    _buildWeightCard(context, currentWeight),
                    _buildWaterCard(context, todayWaterIntake, waterProgress),
                    _buildStepsCard(context, todaySteps, stepsProgress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context, int consumedCalories, double progress) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CaloriesScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CALORIES",
              style: textTheme.labelLarge!.copyWith(color: colorScheme.onTertiaryContainer),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: colorScheme.onTertiaryContainer.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                        ),
                        Text(
                          "${(progress * 100).round()}%",
                          style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$consumedCalories",
                        style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer),
                      ),
                      Text(
                        "cal",
                        style: textTheme.bodyMedium!.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  Text(
                    "last update 3m",
                    style: textTheme.bodySmall!.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, double currentWeight) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => WeightScreenmain())),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WEIGHT",
              style: textTheme.labelLarge!.copyWith(color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Icon(Icons.monitor_weight, size: 70, color: colorScheme.primary),
              ),
            ),
            Text(
              currentWeight.toStringAsFixed(1),
              style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
            ),
            Text(
              "kg",
              style: textTheme.bodyMedium!.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7)),
            ),
            Text(
              "last update 3m",
              style: textTheme.bodySmall!.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard(BuildContext context, double waterIntake, double progress) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const WaterScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.inversePrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WATER",
              style: textTheme.labelLarge!.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Icon(Icons.water_drop, size: 70, color: colorScheme.secondary),
              ),
            ),
            Text(
              waterIntake.toStringAsFixed(2),
              style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            Text(
              "liters",
              style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            Text(
              "last update 3m",
              style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, int steps, double progress) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const StepSummaryScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "STEPS",
              style: textTheme.labelLarge!.copyWith(color: colorScheme.onSecondaryContainer),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: colorScheme.onSecondaryContainer.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                        Icon(Icons.directions_run, size: 30, color: colorScheme.primary),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${NumberFormat('#,###').format(steps)}",
                        style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
                      ),
                      Text(
                        "steps",
                        style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  Text(
                    "last update 3m",
                    style: textTheme.bodySmall!.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}