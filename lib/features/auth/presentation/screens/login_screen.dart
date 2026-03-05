import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/auth_header.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/google_signin_btn.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/login_form.dart';
import '../../data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  // Email Login Field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authRepo.signInWithGoogle();
      // GoRouter's refreshListenable will handle navigation automatically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthHeader(),
                  Gap(60),
                  LoginForm(),
                  Gap(60),
                  GoogleSigninBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
