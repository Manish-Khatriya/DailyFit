// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/step_data_model.dart';

class ApiService {
  static Future<List<StepData>> fetchWeeklySteps() async {
    final response = await http.get(Uri.parse('https://mocki.io/v1/ee1e9c68-0e29-48dc-a259-c83aa18b9dc4')); // replace with your actual API

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final steps = jsonData['steps'] as List;
      return steps.map((e) => StepData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load weekly steps');
    }
  }
}
