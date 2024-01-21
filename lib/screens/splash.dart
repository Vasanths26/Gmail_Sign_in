import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat_app/provider/signin_provider.dart';
import 'package:chat_app/screens/home.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();

    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? nextScreenReplace(context, const LoginScreen())
          : nextScreenReplace(context, const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSplashScreen(
          splashIconSize: 100,
          duration: 3000,
          splash: const Center(
            child: Column(
              children: [
                // Icon(Icons.message, size: 100),
                Image(
                  image: AssetImage("assets/download.png"),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          nextScreen: const HomeScreen(),
        ),
      ),
    );
  }
}
