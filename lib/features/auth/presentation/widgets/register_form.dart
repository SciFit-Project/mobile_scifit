import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/features/auth/data/auth_repository.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthRepository _authRepo = AuthRepository();

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final fullname = _fullnameController.text;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        fullname.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (fullname.length < 3) {
      _showError('Fullname must be at least 3 characters');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    try {
      final response = await _authRepo.signUpWithEmail(
        fullname,
        email,
        password,
      );

      if (!mounted) return;

      if (response != null && response.statusCode == 201) {
        try {
          await _authRepo.signInWithEmail(email, password);

          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;
          context.go('/onboarding');
        } catch (loginError) {
          if (!mounted) return;
          context.go('/login');
          _showError('Account created! Please login to continue.');
        }
      } else {
        _showError('Registration failed. Try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: ${e.toString()}');
    }
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
          controller: _fullnameController,
          hint: 'Full name',
          icon: Icons.person,
        ),
        const Gap(16),
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
        const Gap(16),
        _buildTextField(
          controller: _confirmController,
          hint: 'Confirm password',
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
              "Create Account",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const Gap(16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                color: Colors.grey[500],
                fontSize: 13,
              ),
              children: const [
                TextSpan(text: "Already have an account? "),
                TextSpan(
                  text: "Sign in",
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
