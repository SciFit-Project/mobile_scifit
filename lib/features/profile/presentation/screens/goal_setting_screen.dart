import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  late ProfileGoalType _goalType;
  late ProfileActivityLevel _activityLevel;
  late final TextEditingController _targetWeightController;

  @override
  void initState() {
    super.initState();
    final profile = mockProfileStore.value;
    _goalType = profile.goalType;
    _activityLevel = profile.activityLevel;
    _targetWeightController = TextEditingController(
      text: profile.targetWeightKg.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    final targetWeight = double.tryParse(_targetWeightController.text);
    if (targetWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target weight')),
      );
      return;
    }

    mockProfileStore.patch(
      (current) => current.copyWith(
        goalType: _goalType,
        targetWeightKg: targetWeight,
        activityLevel: _activityLevel,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mock goal updated')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final previewProfile = mockProfileStore.value.copyWith(
      goalType: _goalType,
      activityLevel: _activityLevel,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Goal Type',
              child: Column(
                children: ProfileGoalType.values.map((goal) {
                  final selected = goal == _goalType;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _goalType = goal;
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryLight.withAlpha(10)
                              : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryLight
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppTheme.primaryLight
                                      : null,
                                ),
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected
                                  ? AppTheme.primaryLight
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Target Weight',
              child: TextField(
                controller: _targetWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Target weight (kg)',
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Activity Level',
              child: Column(
                children: ProfileActivityLevel.values.map((activity) {
                  final selected = activity == _activityLevel;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activityLevel = activity;
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryLight.withAlpha(10)
                              : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryLight
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: selected ? AppTheme.primaryLight : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.description,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'TDEE Preview',
              child: Row(
                children: [
                  Expanded(
                    child: _PreviewTile(
                      label: 'BMR',
                      value: '${previewProfile.bmr.round()} kcal',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PreviewTile(
                      label: 'TDEE',
                      value: '${previewProfile.tdee.round()} kcal',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saveGoal,
            child: const Text('Save Goal'),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
