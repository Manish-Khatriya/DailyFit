import 'package:DailyFit/screens/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DailyFit/ThemeProvider.dart';

import 'package:DailyFit/screens/ForgetPassScreen.dart';
import 'package:DailyFit/screens/GenderSelectionScreen.dart';
import 'package:DailyFit/screens/HeightScreen.dart';
import 'package:DailyFit/screens/InterestScreen.dart';
import 'package:DailyFit/screens/SignUp_screen.dart';
import 'package:DailyFit/screens/WeightScreen.dart';
import 'package:DailyFit/screens/graph_screen.dart';
import 'package:DailyFit/screens/home_screen.dart';
import 'package:DailyFit/screens/login_screen.dart';
import 'package:DailyFit/screens/splash_screen.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => RoutesState();
}

class RoutesState extends State<Routes> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'health - DailyFit App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.grey[900],
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white70),
              bodyMedium: TextStyle(color: Colors.white60),
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const HomePage(),
            '/forgot': (context) => const ForgotPassScreen(),
            '/graph': (context) => StepSummaryScreen(),
            '/gender': (context) => GenderSelectionScreen(),
            '/weight': (context) => WeightScreen(),
            '/height': (context) => HeightScreen(),
            '/interest': (context) => InterestScreen(),
            '/profile': (context) => const UserProfileScreen(),
          },
        );
      },
    );
  }
}