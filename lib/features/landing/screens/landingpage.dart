import 'package:flutter/material.dart';
import 'package:whatapp_clone/common/widgets/custom_button.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/login_screen.dart';
import '../../../colors.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                "Welcome to What'sApp",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: size.height / 9),
              Image.asset(
                "assets/bg.png",
                height: 300,
                width: 300,
                color: tabColor,
              ),
              SizedBox(height: size.height / 9),

              const Text(
                "Read our privacy policy..",
                textAlign: TextAlign.center,
                style: TextStyle(color: greyColor),
              ),

              SizedBox(
                width: size.width * 0.7,
                child: CustomButton(
                  text: "AGREE AND CONTINUE",
                  onPressed: () =>
                      Navigator.pushNamed(context, LoginScreen.routeName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
