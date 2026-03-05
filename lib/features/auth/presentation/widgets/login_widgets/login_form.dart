import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/features/auth/data/auth_repository.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthRepository _authRepo = AuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
      _showError('Get and Set Token');


    // if (email.isEmpty || password.isEmpty) {
    //   _showError('Please fill in all fields');
    //   return;
    // }

    // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // if (!emailRegex.hasMatch(email)) {
    //   _showError('Please enter a valid email address');
    //   return;
    // }

    // if (password.length < 8) {
    //   _showError('Password must be at least 8 characters');
    //   return;
    // }

    // try {
    //   final token = await _authRepo.signInWithEmail(
    //     _emailController.text,
    //     _passwordController.text,
    //   );
    //   if (token != null) {
    //     _showError("token: $token");
    //   }
    // } catch (e) {
    //   _showError(e.toString());
    // }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
        ),
        backgroundColor: Colors.red[900],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
        ),
        const Gap(16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const Gap(24),

        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              "Login",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const Gap(16),

        // TextButton(
        //   onPressed: () {},
        //   child: Text(
        //     "Forgot Password?",
        //     style: GoogleFonts.spaceGrotesk(
        //       color: const Color(0xFF555555),
        //       fontSize: 14,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        textInputAction: isPassword
            ? TextInputAction.done
            : TextInputAction.next,
        style: GoogleFonts.spaceGrotesk(color: Colors.black),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF555555), size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.spaceGrotesk(color: const Color(0xFF555555)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
