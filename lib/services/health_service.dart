import 'package:health/health.dart';

class HealthService {
  final health = Health();

  Future<int?> fetchDailySteps() async {
    // CHANGE MADE HERE: configure() is called without any parameters.
    await health.configure();

    var types = [HealthDataType.STEPS];
    var permissions = [HealthDataAccess.READ];

    bool requested = await health.requestAuthorization(
      types,
      permissions: permissions,
    );

    if (requested) {
      var now = DateTime.now();
      var midnight = DateTime(now.year, now.month, now.day);
      int? steps = await health.getTotalStepsInInterval(midnight, now);
      return steps;
    } else {
      print("Authorization not granted.");
      return null;
    }
  }
}
