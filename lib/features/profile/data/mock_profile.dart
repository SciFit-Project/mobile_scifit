import 'package:flutter/material.dart';

enum ProfileGender { male, female, other }

enum ProfileGoalType { fatLoss, muscleGain, maintain }

enum ProfileActivityLevel { sedentary, lightlyActive, active, veryActive }

class MockUserProfile {
  final String name;
  final String email;
  final String? avatarUrl;
  final int avatarColorValue;
  final double weightKg;
  final double heightCm;
  final int age;
  final ProfileGender gender;
  final ProfileGoalType goalType;
  final ProfileActivityLevel activityLevel;
  final DateTime memberSince;
  final int totalWorkouts;
  final double totalVolumeKg;
  final double totalHours;
  final int streakDays;
  final bool healthConnectGranted;

  const MockUserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.avatarColorValue,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.goalType,
    required this.activityLevel,
    required this.memberSince,
    required this.totalWorkouts,
    required this.totalVolumeKg,
    required this.totalHours,
    required this.streakDays,
    required this.healthConnectGranted,
  });

  factory MockUserProfile.seed() {
    final now = DateTime.now();

    return MockUserProfile(
      name: '',
      email: '',
      avatarUrl: null,
      avatarColorValue: const Color(0xFF2F66F3).toARGB32(),
      weightKg: 0,
      heightCm: 0,
      age: 25,
      gender: ProfileGender.other,
      goalType: ProfileGoalType.maintain,
      activityLevel: ProfileActivityLevel.sedentary,
      memberSince: now,
      totalWorkouts: 0,
      totalVolumeKg: 0,
      totalHours: 0,
      streakDays: 0,
      healthConnectGranted: false,
    );
  }

  MockUserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    int? avatarColorValue,
    double? weightKg,
    double? heightCm,
    int? age,
    ProfileGender? gender,
    ProfileGoalType? goalType,
    ProfileActivityLevel? activityLevel,
    DateTime? memberSince,
    int? totalWorkouts,
    double? totalVolumeKg,
    double? totalHours,
    int? streakDays,
    bool? healthConnectGranted,
  }) {
    return MockUserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goalType: goalType ?? this.goalType,
      activityLevel: activityLevel ?? this.activityLevel,
      memberSince: memberSince ?? this.memberSince,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      totalHours: totalHours ?? this.totalHours,
      streakDays: streakDays ?? this.streakDays,
      healthConnectGranted: healthConnectGranted ?? this.healthConnectGranted,
    );
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SC';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  double get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    switch (gender) {
      case ProfileGender.male:
        return base + 5;
      case ProfileGender.female:
        return base - 161;
      case ProfileGender.other:
        return base - 78;
    }
  }

  double get maintenanceCalories => bmr * activityLevel.multiplier;

  double get tdee {
    switch (goalType) {
      case ProfileGoalType.fatLoss:
        return maintenanceCalories - 500;
      case ProfileGoalType.muscleGain:
        return maintenanceCalories + 500;
      case ProfileGoalType.maintain:
        return maintenanceCalories;
    }
  }
}

extension ProfileGenderX on ProfileGender {
  String get label {
    switch (this) {
      case ProfileGender.male:
        return 'Male';
      case ProfileGender.female:
        return 'Female';
      case ProfileGender.other:
        return 'Other';
    }
  }
}

extension ProfileGoalTypeX on ProfileGoalType {
  String get label {
    switch (this) {
      case ProfileGoalType.fatLoss:
        return 'Fat Loss';
      case ProfileGoalType.muscleGain:
        return 'Muscle Gain';
      case ProfileGoalType.maintain:
        return 'Maintain';
    }
  }
}

extension ProfileActivityLevelX on ProfileActivityLevel {
  String get label {
    switch (this) {
      case ProfileActivityLevel.sedentary:
        return 'Sedentary';
      case ProfileActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ProfileActivityLevel.active:
        return 'Active';
      case ProfileActivityLevel.veryActive:
        return 'Very Active';
    }
  }

  double get multiplier {
    switch (this) {
      case ProfileActivityLevel.sedentary:
        return 1.2;
      case ProfileActivityLevel.lightlyActive:
        return 1.375;
      case ProfileActivityLevel.active:
        return 1.55;
      case ProfileActivityLevel.veryActive:
        return 1.725;
    }
  }

  String get description {
    switch (this) {
      case ProfileActivityLevel.sedentary:
        return 'Little to no exercise during the week';
      case ProfileActivityLevel.lightlyActive:
        return 'Light training or walking 1-3 days/week';
      case ProfileActivityLevel.active:
        return 'Regular training 3-5 days/week';
      case ProfileActivityLevel.veryActive:
        return 'Hard training or sports 6-7 days/week';
    }
  }
}

class MockProfileStore extends ValueNotifier<MockUserProfile> {
  MockProfileStore() : super(MockUserProfile.seed());

  void update(MockUserProfile profile) {
    value = profile;
  }

  void patch(MockUserProfile Function(MockUserProfile current) updateFn) {
    value = updateFn(value);
  }

  void reset() {
    value = MockUserProfile.seed();
  }
}

final mockProfileStore = MockProfileStore();

MockUserProfile defaultMockUserProfile() => MockUserProfile.seed();
