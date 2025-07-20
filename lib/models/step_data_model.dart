class StepData {
  final String day;
  final int count;

  StepData({required this.day, required this.count});

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      day: json['day'],
      count: json['count'],
    );
  }
}
