import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/auth_header.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                children: [AuthHeader(), Gap(60), RegisterForm()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
