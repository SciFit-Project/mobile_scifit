import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/auth_header.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/google_signin_btn.dart';
import 'package:mobile_scifit/features/auth/presentation/widgets/login_widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

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
