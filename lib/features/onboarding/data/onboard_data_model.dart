// onboard_data_model.dart
class OnboardingData {
  int? age;
  double? height;
  double? weight;
  String? gender;
  String? plan;
  String? activityLevel;

  Map<String, dynamic> toJson() => {
    'age': age,
    'height': height,
    'weight': weight,
    'gender': gender,
    'plan': plan,
    'activity_level': activityLevel,
  };
}
