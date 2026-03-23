import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/plan_store.dart';
import 'package:mobile_scifit/features/plans/data/plans_repository.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class PlanDetailsScreen extends StatefulWidget {
  final String id;
  const PlanDetailsScreen({super.key, required this.id});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final PlansRepository _plansRepository = PlansRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _syncedPlanId;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    try {
      await _plansRepository.fetchPlanById(widget.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load plan details')),
      );
    }
  }

  Future<void> _deactivatePlan(MyPlans plan) async {
    try {
      await _plansRepository.deactivatePlan(plan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plan.name} deactivated')),
      );
      context.go('/plans');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to deactivate plan')),
      );
    }
  }

  Future<void> _savePlan(MyPlans plan) async {
    final updatedName = _nameController.text.trim();
    final updatedDescription = _descriptionController.text.trim();

    if (updatedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _plansRepository.savePlan(
        MyPlans(
          id: plan.id,
          userId: plan.userId,
          name: updatedName,
          description: updatedDescription,
          isActive: plan.isActive,
          createdAt: plan.createdAt,
          days: plan.days,
          stats: plan.stats,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan updated')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save plan')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deletePlan(MyPlans plan) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Plan'),
          content: Text('Delete "${plan.name}" permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);
    try {
      await _plansRepository.deletePlan(plan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plan.name} deleted')),
      );
      context.go('/plans');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete plan')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _syncControllers(MyPlans plan) {
    if (_syncedPlanId == plan.id &&
        _nameController.text == plan.name &&
        _descriptionController.text == plan.description) {
      return;
    }

    _syncedPlanId = plan.id;
    _nameController.text = plan.name;
    _descriptionController.text = plan.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ValueListenableBuilder<List<MyPlans>>(
          valueListenable: planStore,
          builder: (context, plans, _) {
            final editPlan = plans.where((p) => p.id == widget.id).firstOrNull;
            return Text(
              editPlan?.name ?? 'Plan Details',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      body: ValueListenableBuilder<List<MyPlans>>(
        valueListenable: planStore,
        builder: (context, plans, _) {
          final editPlan = plans.where((p) => p.id == widget.id).firstOrNull;
          if (editPlan == null) {
            return const Center(child: Text('Plan not found'));
          }
          _syncControllers(editPlan);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _planDetailsCard(editPlan),
                  const SizedBox(height: 20),
                  const Text(
                    "Workout Days",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ...editPlan.days.map(
                    (day) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                      child: (_workoutDays(day, widget.id)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _workoutDays(WorkoutDay day, String planId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Day ${day.dayNumber.toString()}: ${day.name}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push('/plans/$planId/days/${day.id}/edit'),
                label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ), // The icon widget
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  day.exercises.map((e) => e.name).join(" • "),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planDetailsCard(MyPlans plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: AppTheme.primaryLight, width: 4),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (plans.isActive)
                    Badge(
                      label: const Text(
                        "ACTIVE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      backgroundColor: const Color(0xFF16A34A).withAlpha(80),
                    ),
                ],
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withAlpha(80),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center_sharp,
                    size: 16,
                    color: Colors.black.withAlpha(80),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ('${plans.stats.totalExercises} exercises'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withAlpha(80),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.black.withAlpha(80),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ('${plans.stats.totalDays} days'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withAlpha(80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : () => _savePlan(plans),
                        icon: const Icon(Icons.save),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: _primaryButtonStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: plans.isActive
                            ? () => _deactivatePlan(plans)
                            : null,
                        icon: const Icon(Icons.power_settings_new),
                        label: Text(
                          'Deactivate',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: _secondaryButtonStyle(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _isDeleting ? null : () => _deletePlan(plans),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(
                    _isDeleting ? 'Deleting...' : 'Delete Plan',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black87,
      side: const BorderSide(color: Colors.black26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
