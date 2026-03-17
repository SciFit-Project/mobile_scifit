import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanDetails extends StatelessWidget {
  final TextEditingController planName;
  final TextEditingController planDescription;
  const PlanDetails({
    super.key,
    required this.planName,
    required this.planDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            "Create Your Plan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Define the core program plan"),

          const SizedBox(height: 10),
          const Text("Plan name"),
          _buildTextField(controller: planName, hint: 'Name'),

          const SizedBox(height: 20),
          const Text("Plan Description"),
          _buildTextField(controller: planDescription, hint: 'Description'),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        style: GoogleFonts.spaceGrotesk(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.spaceGrotesk(color: const Color(0xFF555555)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
