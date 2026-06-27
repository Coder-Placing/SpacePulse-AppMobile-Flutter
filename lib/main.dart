import 'package:flutter/material.dart';
import 'package:tfmoviles2/iam/presentation/views/login_view.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpacePulse',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryButton,
          surface: AppColors.cardBackground,
        ),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
