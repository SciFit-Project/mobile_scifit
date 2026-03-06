import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health/health.dart'; // อย่าลืมลงทะเบียน package: health ใน pubspec.yaml
import 'package:mobile_scifit/core/theme/app_theme.dart';

class Permisson extends StatefulWidget {
  final Function(bool isValid)
  onValidChanged; 

  const Permisson({super.key, required this.onValidChanged});

  @override
  State<Permisson> createState() => _PermissonState();
}

class _PermissonState extends State<Permisson> {
  bool _isAuthorized = false;

  final types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WEIGHT,
  ];

  Future<void> _requestPermission() async {
    Health health = Health();

    if (Theme.of(context).platform == TargetPlatform.android) {
      var status = await health.getHealthConnectSdkStatus();
      if (status != HealthConnectSdkStatus.sdkAvailable) {
        await health.installHealthConnect();
        return;
      }
    }

    try {
      bool requested = await health.requestAuthorization(types);

      setState(() {
        _isAuthorized = requested;
      });

      widget.onValidChanged(requested);

      if (requested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Health data connected successfully!")),
        );
      }
    } catch (e) {
      print("Error requesting health data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              size: 80,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            "Sync Health Data",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "We need to connect with Apple Health or Health Connect to accurately analyze your activity and fitness data.",
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.mutedLight,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAuthorized ? null : _requestPermission,
              icon: Icon(_isAuthorized ? Icons.check_circle : Icons.add_link),
              label: Text(_isAuthorized ? "Connected" : "Connect Health App"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAuthorized
                    ? Colors.green
                    : AppTheme.primaryLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_isAuthorized)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                "Connection successful! Tap the button below to get started.",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
