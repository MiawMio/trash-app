
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trash_app/firebase_options.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          AppColors.primaryGreen.value,
          const <int, Color>{
            50: Color(0xFFE8F5E8),
            100: Color(0xFFC8E6C9),
            200: Color(0xFFA5D6A7),
            300: Color(0xFF81C784),
            400: Color(0xFF66BB6A),
            500: AppColors.primaryGreen,
            600: Color(0xFF43A047),
            700: Color(0xFF388E3C),
            800: Color(0xFF2E7D32),
            900: Color(0xFF1B5E20),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.grey,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.textFieldBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
