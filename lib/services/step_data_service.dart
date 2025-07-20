import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/step_data_model.dart';

class StepDataService {
  Future<List<StepData>> fetchWeeklySteps() async {
    final response = await http.get(Uri.parse('https://mocki.io/v1/6632e9f1-5e2e-426d-9d6a-91a5f6d2e647')); // Replace with your actual API

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> stepsJson = data['steps'];
      return stepsJson.map((json) => StepData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load step data');
    }
  }
}
