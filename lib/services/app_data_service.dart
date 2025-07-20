// lib/services/app_data_service.dart
import 'package:flutter/services.dart' show rootBundle; // For loading JSON file
import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart'; // For debugPrint
import 'package:intl/intl.dart';

// --- Data Models ---

// General Daily Health Summary Data
class DailyHealthSummaryData {
  final DateTime date;
  final int steps;
  final double caloriesBurned;
  final double waterIntake;

  DailyHealthSummaryData({
    required this.date,
    required this.steps,
    required this.caloriesBurned,
    required this.waterIntake,
  });

  factory DailyHealthSummaryData.fromJson(Map<String, dynamic> json) {
    return DailyHealthSummaryData(
      date: DateTime.parse(json['date']),
      steps: json['steps'] as int,
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      waterIntake: (json['waterIntake'] as num).toDouble(),
    );
  }
}

// Daily Macronutrient Details
class DailyMacroData {
  final DateTime date;
  final int carbsGrams;
  final int proteinGrams;
  final int fatGrams;

  DailyMacroData({
    required this.date,
    required this.carbsGrams,
    required this.proteinGrams,
    required this.fatGrams,
  });

  int get totalCalories => (carbsGrams * 4) + (proteinGrams * 4) + (fatGrams * 9);

  factory DailyMacroData.fromJson(Map<String, dynamic> json) {
    return DailyMacroData(
      date: DateTime.parse(json['date']),
      carbsGrams: json['carbsGrams'] as int,
      proteinGrams: json['proteinGrams'] as int,
      fatGrams: json['fatGrams'] as int,
    );
  }
}

// Weight History Data
class WeightData {
  final DateTime date;
  final double weightKg;

  WeightData({
    required this.date,
    required this.weightKg,
  });

  factory WeightData.fromJson(Map<String, dynamic> json) {
    return WeightData(
      date: DateTime.parse(json['date']),
      weightKg: (json['weightKg'] as num).toDouble(),
    );
  }
}

// User Goals Data
class UserGoals {
  final int dailyCalorieGoal;
  final int dailyStepGoal;
  final double dailyWaterGoalLitres;
  final int targetWeightKg;

  UserGoals({
    required this.dailyCalorieGoal,
    required this.dailyStepGoal,
    required this.dailyWaterGoalLitres,
    required this.targetWeightKg,
  });

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      dailyCalorieGoal: json['dailyCalorieGoal'] as int,
      dailyStepGoal: json['dailyStepGoal'] as int,
      dailyWaterGoalLitres: (json['dailyWaterGoalLitres'] as num).toDouble(),
      targetWeightKg: json['targetWeightKg'] as int,
    );
  }
}

// --- Service Class ---

class AppDataService {
  static const String _mockDataPath = 'assets/data/mock_app_data.json';
  Map<String, dynamic>? _cachedData; // To store data after first fetch

  AppDataService() {
    debugPrint("AppDataService initialized. Ready to load data from $_mockDataPath");
  }

  /// Loads and parses the entire mock JSON data from the asset.
  Future<Map<String, dynamic>> _loadAndParseJson() async {
    if (_cachedData != null) {
      debugPrint("Using cached data.");
      return _cachedData!;
    }
    await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay
    try {
      String jsonString = await rootBundle.loadString(_mockDataPath);
      _cachedData = json.decode(jsonString);
      debugPrint("JSON data loaded and cached successfully.");
      return _cachedData!;
    } catch (e) {
      debugPrint("Error loading or parsing $_mockDataPath: $e");
      // Optionally re-throw or return an error state
      return {}; // Return an empty map on error
    }
  }

  /// Fetches User Goals.
  Future<UserGoals?> fetchUserGoals() async {
    final Map<String, dynamic> jsonData = await _loadAndParseJson();
    if (jsonData.containsKey('userGoals')) {
      return UserGoals.fromJson(jsonData['userGoals']);
    }
    return null;
  }

  /// Fetches daily health summary data for the last 'numDays' days.
  Future<Map<String, DailyHealthSummaryData>> fetchLastNDaysHealthSummary(int numDays) async {
    final Map<String, dynamic> jsonData = await _loadAndParseJson();
    final List<dynamic> rawList = jsonData['dailyHealthSummary'] ?? [];

    Map<String, DailyHealthSummaryData> dataMap = {};
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    for (int i = numDays - 1; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = formatter.format(date);

      var dataForDate = rawList.firstWhere(
            (item) => item['date'] == formattedDate,
        orElse: () => null,
      );

      if (dataForDate != null) {
        dataMap[formattedDate] = DailyHealthSummaryData.fromJson(dataForDate);
      } else {
        // If data not found for a specific date, provide default/zero values
        dataMap[formattedDate] = DailyHealthSummaryData(
          date: date,
          steps: 0,
          caloriesBurned: 0.0,
          waterIntake: 0.0,
        );
      }
    }
    return dataMap;
  }

  /// Fetches daily macronutrient data for the last 'numDays' days.
  Future<Map<String, DailyMacroData>> fetchLastNDaysMacroData(int numDays) async {
    final Map<String, dynamic> jsonData = await _loadAndParseJson();
    final List<dynamic> rawList = jsonData['dailyMacroDetails'] ?? [];

    Map<String, DailyMacroData> dataMap = {};
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    for (int i = numDays - 1; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = formatter.format(date);

      var dataForDate = rawList.firstWhere(
            (item) => item['date'] == formattedDate,
        orElse: () => null,
      );

      if (dataForDate != null) {
        dataMap[formattedDate] = DailyMacroData.fromJson(dataForDate);
      } else {
        dataMap[formattedDate] = DailyMacroData(
          date: date,
          carbsGrams: 0,
          proteinGrams: 0,
          fatGrams: 0,
        );
      }
    }
    return dataMap;
  }

  /// Fetches all weight history data.
  Future<List<WeightData>> fetchWeightHistory() async {
    final Map<String, dynamic> jsonData = await _loadAndParseJson();
    final List<dynamic> rawList = jsonData['weightHistory'] ?? [];
    return rawList.map((item) => WeightData.fromJson(item)).toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date ascending
  }
}