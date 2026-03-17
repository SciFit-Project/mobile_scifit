import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/onboarding/data/onboard_data_model.dart';
import 'package:mobile_scifit/features/onboarding/data/onboarding_repository.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/onboard_header.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/activity.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/goal.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/infomation.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/permisson.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final PageController _pageController = PageController();
  final OnboardingData _collectedData = OnboardingData();
  final OnboardingRepository _onboardingRepository = OnboardingRepository();

  int _currentPage = 0;
  bool _isSubmitting = false;
  final List<bool> _isPageValid = [false, false, false, false];
  late List<Widget> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      Information(
        onValidChanged: (isValid, age, h, w, g) {
          setState(() {
            _isPageValid[0] = isValid;
            _collectedData.age = age;
            _collectedData.height = h;
            _collectedData.weight = w;
            _collectedData.gender = g;
          });
        },
      ),
      Goal(
        onValidChanged: (isValid, plan) {
          setState(() {
            _isPageValid[1] = isValid;
            _collectedData.plan = plan;
          });
        },
      ),
      Activity(
        onValidChanged: (isValid, activity) {
          setState(() {
            _isPageValid[2] = isValid;
            _collectedData.activityLevel = activity;
          });
        },
      ),
      Permisson(
        onValidChanged: (isValid) {
          setState(() {
            _isPageValid[3] = isValid;
          });
        },
      ),
    ];
  }

  Future<void> _submitData() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _onboardingRepository.submitProfile(
        _collectedData,
      );

      if (!mounted) return;

      if (response != null && response.statusCode == 200) {
        _applyLocalProfile();
        context.go('/home');
        return;
      }

      _showError('Could not save your profile. Please try again.');
    } catch (e) {
      if (!mounted) return;
      _showError('Could not save your profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _applyLocalProfile() {
    final profile = mockProfileStore.value;
    final age = _collectedData.age ?? profile.age;

    mockProfileStore.patch(
      (current) => current.copyWith(
        weightKg: _collectedData.weight ?? current.weightKg,
        heightCm: _collectedData.height ?? current.heightCm,
        age: age,
        gender: _mapGender(_collectedData.gender) ?? current.gender,
        goalType: _mapGoal(_collectedData.plan) ?? current.goalType,
        activityLevel:
            _mapActivityLevel(_collectedData.activityLevel) ??
            current.activityLevel,
        healthConnectGranted: _isPageValid[3],
      ),
    );
  }

  ProfileGender? _mapGender(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return ProfileGender.male;
      case 'female':
        return ProfileGender.female;
      case 'other':
        return ProfileGender.other;
      default:
        return null;
    }
  }

  ProfileGoalType? _mapGoal(String? goal) {
    switch (goal?.toLowerCase()) {
      case 'cutting':
        return ProfileGoalType.fatLoss;
      case 'bulking':
        return ProfileGoalType.muscleGain;
      case 'maintenance':
        return ProfileGoalType.maintain;
      default:
        return null;
    }
  }

  ProfileActivityLevel? _mapActivityLevel(String? activityLevel) {
    switch (activityLevel?.toLowerCase()) {
      case 'sedentary':
        return ProfileActivityLevel.sedentary;
      case 'light exercise':
        return ProfileActivityLevel.lightlyActive;
      case 'moderate exercise':
        return ProfileActivityLevel.active;
      case 'heavy exercise':
        return ProfileActivityLevel.veryActive;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: OnboardHeader(),
            ),

            SmoothPageIndicator(
              controller: _pageController,
              count: _steps.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppTheme.primaryLight,
                dotColor: AppTheme.primaryLight.withAlpha(20),
                dotHeight: 4,
                dotWidth: 4,
                expansionFactor: 4,
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: _steps,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppTheme.primaryLight.withAlpha(50),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(color: AppTheme.primaryLight),
                        ),
                      ),
                    ),

                  if (_currentPage > 0) const SizedBox(width: 12),

                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: _isPageValid[_currentPage]
                          && !_isSubmitting
                          ? () {
                              if (_currentPage < _steps.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _submitData();
                              }
                            }
                          : null,
                      child: Text(
                        _isSubmitting
                            ? "Saving..."
                            : _currentPage == _steps.length - 1
                            ? "Get Started"
                            : "Next",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
