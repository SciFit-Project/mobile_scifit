import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class Information extends StatefulWidget {
  final Function(bool isValid, int? age, double? h, double? w, String? g)
  onValidChanged;

  const Information({super.key, required this.onValidChanged});

  @override
  State<Information> createState() => _InfomationState();
}

class _InfomationState extends State<Information>
    with AutomaticKeepAliveClientMixin {
  String? _selectedGender;

  @override
  bool get wantKeepAlive => true;

  // เพิ่ม Controller
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _checkValidation() {
    int? age = int.tryParse(_ageController.text);
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    bool isAgeValid = age != null && age >= 10 && age <= 100;
    bool isHeightValid = height != null && height >= 100 && height <= 250;
    bool isWeightValid = weight != null && weight >= 30 && weight <= 300;
    bool isGenderSelected = _selectedGender != null;

    bool isValid =
        isAgeValid && isHeightValid && isWeightValid && isGenderSelected;

    widget.onValidChanged(isValid, age, height, weight, _selectedGender);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: "Age",
            hint: "e.g. 25",
            icon: Icons.cake,
            controller: _ageController,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: "Height (cm)",
            hint: "e.g. 175",
            icon: Icons.height,
            controller: _heightController,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: "Weight (kg)",
            hint: "e.g. 70",
            icon: Icons.monitor_weight_outlined,
            controller: _weightController,
          ),

          const SizedBox(height: 32),

          Text(
            "Gender",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildGenderOption("Male", Icons.male)),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderOption("Female", Icons.female)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {});
            _checkValidation();
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryLight),
            filled: true,
            fillColor: AppTheme.primaryLight.withAlpha(5),
            errorText: _getErrorText(label, controller.text),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String? _getErrorText(String label, String value) {
    if (value.isEmpty) return null;
    num? val = num.tryParse(value);
    if (val == null) return "Invalid number";

    if (label == "Age" && (val < 10 || val > 100)) {
      return "Age must be 10-100";
    }
    if (label == "Height (cm)" && (val < 100 || val > 250)) {
      return "Height must be 100-250";
    }
    if (label == "Weight (kg)" && (val < 30 || val > 300)) {
      return "Weight must be 30-300";
    }

    return null;
  }

  Widget _buildGenderOption(String value, IconData icon) {
    bool isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedGender = value;
        _checkValidation();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : AppTheme.mutedLight.withAlpha(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppTheme.mutedLight),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: isSelected ? Colors.white : AppTheme.mutedLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
