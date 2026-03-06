// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/onboarding/data/onboard_data_model.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/onboard_header.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/activity.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/goal.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/infomation.dart';
import 'package:mobile_scifit/features/onboarding/presentation/widgets/steps/permisson.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final PageController _pageController = PageController();
  final OnboardingData _collectedData = OnboardingData();

  int _currentPage = 0;
  final List<bool> _isPageValid = [false, false, false, true];
  late List<Widget> _steps;

  @override
  void initState() {
    super.initState();
    // สร้าง List ครั้งเดียวตอนเริ่มต้น
    super.initState();
    _steps = [
      Information(
        onValidChanged: (isValid, age, h, w, g) {
          setState(() {
            _isPageValid[0] = isValid;
            // 2. รับข้อมูลจากหน้า Information
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
      const Permisson(),
    ];
  }

  void _submitData() {
    print("--- CLICKED GET STARTED ---");

    print("Age: ${_collectedData.age}");
    print("Height: ${_collectedData.height}");
    print("Weight: ${_collectedData.weight}");
    print("Gender: ${_collectedData.gender}");
    print("Plan: ${_collectedData.plan}");
    print("Activity: ${_collectedData.activityLevel}");
    // print("Final Data collected: ${_collectedData.toJson()}");

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
                  // 1. ปุ่ม Back (จะโชว์เมื่อไม่ใช่หน้าแรก)
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

                  // ระยะห่างระหว่างปุ่ม
                  if (_currentPage > 0) const SizedBox(width: 12),

                  // 2. ปุ่ม Next
                  Expanded(
                    flex: 4, // ให้ปุ่ม Next กว้างกว่าปุ่ม Back
                    child: ElevatedButton(
                      onPressed: _isPageValid[_currentPage]
                          ? () {
                              if (_currentPage < _steps.length - 1) {
                                // ถ้ายังไม่ถึงหน้าสุดท้าย ให้ไปหน้าถัดไป
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                // ถ้าเป็นหน้าสุดท้าย (Permission/Finish) ให้ส่งข้อมูล
                                _submitData();
                              }
                            }
                          : null, // ปุ่มจางถ้า Validate ไม่ผ่าน
                      child: Text(
                        _currentPage == _steps.length - 1
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
