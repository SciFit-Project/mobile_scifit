import 'package:dio/dio.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';
import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/data/plan_store.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class PlansRepository {
  PlansRepository({Dio? dio}) : _dio = dio ?? DioClient().instance;

  final Dio _dio;
  List<Exercise>? _exerciseCache;

  Future<List<MyPlans>> fetchPlans() async {
    final response = await _dio.get('/api/plans');
    final items = (response.data['data'] as List? ?? const []);

    if (items.isEmpty) {
      planStore.value = [];
      return const [];
    }

    final plans = await Future.wait(
      items.map((item) async {
        final id = item['id'] as String;
        return _fetchPlanDetail(id);
      }),
    );

    planStore.value = plans;
    return plans;
  }

  Future<MyPlans?> fetchPlanById(String id) async {
    final plan = await _fetchPlanDetail(id);
    _upsertPlan(plan);
    return plan;
  }

  Future<MyPlans?> fetchActivePlan() async {
    final plans = await fetchPlans();
    for (final plan in plans) {
      if (plan.isActive) return plan;
    }
    return null;
  }

  Future<WorkoutDay?> fetchWorkoutDayById(String dayId) async {
    final cached = findWorkoutDayById(dayId);
    if (cached != null) return cached;

    await fetchPlans();
    return findWorkoutDayById(dayId);
  }

  Future<MyPlans> createPlan({
    required String name,
    required String description,
    required List<WorkoutDay> days,
  }) async {
    if (!_canSyncPlan(days)) {
      // The current create screen still builds draft days without exercises.
      final newPlan = MyPlans(
        id: 'plan-${DateTime.now().microsecondsSinceEpoch}',
        userId: 'current-user',
        name: name,
        description: description,
        isActive: currentPlans.isEmpty,
        createdAt: DateTime.now(),
        days: days,
        stats: _buildStats(days),
      );

      planStore.value = [...currentPlans, newPlan];
      return newPlan;
    }

    final response = await _dio.post(
      '/api/plans',
      data: _toPlanPayload(
        name: name,
        description: description,
        frequency: days.length,
        days: days,
      ),
    );

    final rawPlan = response.data['plan'] ?? response.data['data'];
    final created = _mapPlan(rawPlan);
    _upsertPlan(created);
    return created;
  }

  Future<MyPlans> savePlan(MyPlans plan) async {
    final response = await _dio.put(
      '/api/plans/${plan.id}',
      data: _toPlanPayload(
        name: plan.name,
        description: plan.description,
        frequency: plan.days.length,
        days: plan.days,
      ),
    );

    final rawPlan = response.data['plan'] ?? response.data['data'];
    MyPlans updated;
    if (_looksLikePlanDetail(rawPlan)) {
      updated = _mapPlan(rawPlan);
    } else {
      updated = (await _fetchPlanDetail(plan.id));
    }

    _upsertPlan(updated);
    return updated;
  }

  Future<void> deletePlan(String id) async {
    await _dio.delete('/api/plans/$id');
    planStore.value = currentPlans.where((plan) => plan.id != id).toList();
  }

  Future<void> activatePlan(String? planId) async {
    if (planId == null) {
      return;
    }

    await _dio.put('/api/plans/$planId/activate');
    await fetchPlans();
  }

  Future<void> deactivatePlan(String planId) async {
    await _dio.put('/api/plans/$planId/deactivate');
    await fetchPlans();
  }

  Future<MyPlans?> saveDay({
    required String planId,
    required String dayId,
    required String dayName,
    required List<PlanExercise> exercises,
  }) async {
    final plan = findPlanById(planId) ?? await fetchPlanById(planId);
    if (plan == null) return null;

    final updatedDays = [
      for (final day in plan.days)
        if (day.id == dayId)
          WorkoutDay(
            id: day.id,
            dayNumber: day.dayNumber,
            name: dayName,
            exercises: exercises,
          )
        else
          day,
    ];

    final updatedPlan = MyPlans(
      id: plan.id,
      userId: plan.userId,
      name: plan.name,
      description: plan.description,
      isActive: plan.isActive,
      createdAt: plan.createdAt,
      days: updatedDays,
      stats: _buildStats(updatedDays, previousTimesUsed: plan.stats.timesUsed),
    );

    return savePlan(updatedPlan);
  }

  Future<List<Exercise>> fetchExercises() async {
    if (_exerciseCache != null) return _exerciseCache!;

    final response = await _dio.get('/api/exercises');
    final items = (response.data['data'] as List? ?? const []);

    final exercises = items.map<Exercise>((item) {
      return Exercise(
        id: item['id'] as String,
        name: item['name'] as String,
        muscleGroup: _parseMuscleGroup(
          (item['muscle_group'] ?? 'core').toString(),
        ),
        secondaryMuscles: (item['secondary_muscles'] as List?)
            ?.map((muscle) => muscle.toString())
            .toList(),
        equipment: _parseEquipment(item['equipment']?.toString()),
        instruction: item['instruction']?.toString(),
        createdAt:
            DateTime.tryParse((item['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );
    }).toList();

    _exerciseCache = exercises;
    return exercises;
  }

  List<Exercise> getExercises() {
    return _exerciseCache ?? mockExercises;
  }

  Future<MyPlans> _fetchPlanDetail(String id) async {
    final response = await _dio.get('/api/plans/$id');
    return _mapPlan(response.data['data']);
  }

  void _upsertPlan(MyPlans plan) {
    final updated = [...currentPlans];
    final index = updated.indexWhere((current) => current.id == plan.id);
    if (index >= 0) {
      updated[index] = plan;
    } else {
      updated.add(plan);
    }
    planStore.value = updated;
  }

  bool _looksLikePlanDetail(dynamic rawPlan) {
    return rawPlan is Map<String, dynamic> && rawPlan['days'] is List;
  }

  bool _canSyncPlan(List<WorkoutDay> days) {
    return days.isNotEmpty &&
        days.every((day) => day.exercises.isNotEmpty);
  }

  Map<String, dynamic> _toPlanPayload({
    required String name,
    required String description,
    required int frequency,
    required List<WorkoutDay> days,
  }) {
    return {
      'name': name,
      'description': description,
      'frequency': frequency,
      'days': days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        return {
          'name': day.name,
          'dayOfWeek': _toApiDayOfWeek(day.dayNumber, index),
          'order': index,
          'exercises': day.exercises.asMap().entries.map((exerciseEntry) {
            final exercise = exerciseEntry.value;
            return {
              'exerciseId': exercise.exerciseId,
              'sets': exercise.sets,
              'repsMin': exercise.reps,
              'repsMax': exercise.reps,
              'order': exerciseEntry.key,
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  int _toApiDayOfWeek(int dayNumber, int fallbackIndex) {
    if (dayNumber >= 0 && dayNumber <= 6) return dayNumber;
    if (dayNumber >= 1 && dayNumber <= 7) return dayNumber - 1;
    return fallbackIndex % 7;
  }

  MyPlans _mapPlan(dynamic raw) {
    final days = ((raw['days'] as List?) ?? const [])
        .map<WorkoutDay>((day) => _mapDay(day))
        .toList();

    return MyPlans(
      id: raw['id'] as String,
      userId: (raw['user_id'] ?? raw['userId'] ?? '') as String,
      name: (raw['name'] ?? '') as String,
      description: (raw['description'] ?? _buildDescription(
        frequency: (raw['frequency'] ?? days.length) as int,
        totalDays: days.length,
      )) as String,
      isActive: (raw['is_active'] ?? raw['isActive'] ?? false) as bool,
      createdAt: DateTime.tryParse(
            (raw['created_at'] ?? raw['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      days: days,
      stats: _buildStats(days),
    );
  }

  WorkoutDay _mapDay(dynamic raw) {
    final exercises = ((raw['exercises'] as List?) ?? const [])
        .map<PlanExercise>((exercise) => _mapExercise(exercise))
        .toList();

    return WorkoutDay(
      id: raw['id'] as String,
      dayNumber: ((raw['order'] as int?) ?? 0) + 1,
      name: (raw['name'] ?? '') as String,
      exercises: exercises,
    );
  }

  PlanExercise _mapExercise(dynamic raw) {
    final exercise = raw['exercise'] as Map<String, dynamic>?;
    final repsMin = raw['reps_min'] as int?;
    final repsMax = raw['reps_max'] as int?;

    return PlanExercise(
      exerciseId:
          (raw['exercise_id'] ?? exercise?['id'] ?? raw['id'] ?? '') as String,
      name: (exercise?['name'] ?? raw['name'] ?? '') as String,
      muscleGroup: _formatMuscleGroup(
        (exercise?['muscle_group'] ?? raw['muscleGroup'] ?? 'Unknown')
            .toString(),
      ),
      sets: (raw['sets'] ?? 0) as int,
      reps: repsMax ?? repsMin ?? 0,
      order: (raw['order'] ?? 0) as int,
    );
  }

  String _buildDescription({
    required int frequency,
    required int totalDays,
  }) {
    final days = totalDays == 0 ? frequency : totalDays;
    return '$days days/week';
  }

  String _formatMuscleGroup(String value) {
    if (value.isEmpty) return 'Unknown';
    final normalized = value.replaceAll('_', ' ').trim();
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  MuscleGroup _parseMuscleGroup(String value) {
    switch (value) {
      case 'chest':
        return MuscleGroup.chest;
      case 'back':
        return MuscleGroup.back;
      case 'legs':
        return MuscleGroup.legs;
      case 'shoulders':
        return MuscleGroup.shoulders;
      case 'arms':
        return MuscleGroup.arms;
      case 'core':
      default:
        return MuscleGroup.core;
    }
  }

  Equipment? _parseEquipment(String? value) {
    switch (value) {
      case 'barbell':
        return Equipment.barbell;
      case 'dumbbell':
        return Equipment.dumbbell;
      case 'cable':
        return Equipment.cable;
      case 'machine':
        return Equipment.machine;
      case 'bodyweight':
        return Equipment.bodyweight;
      case 'band':
        return Equipment.band;
      default:
        return null;
    }
  }

  PlanStats _buildStats(List<WorkoutDay> days, {int previousTimesUsed = 0}) {
    final totalExercises = days.fold<int>(
      0,
      (sum, day) => sum + day.exercises.length,
    );

    final estDurationMin = days.isEmpty
        ? 0
        : (days
                    .map((day) => day.exercises.length * 8)
                    .reduce((a, b) => a + b) ~/
                days.length)
            .clamp(20, 120);

    return PlanStats(
      totalDays: days.length,
      totalExercises: totalExercises,
      estDurationMin: estDurationMin,
      timesUsed: previousTimesUsed,
    );
  }
}
