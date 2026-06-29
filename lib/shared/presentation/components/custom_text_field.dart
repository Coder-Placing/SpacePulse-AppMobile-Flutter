import 'package:flutter/material.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final bool isLight;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.isPassword = false,
    this.isLight = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: isLight ? AppColors.lightText : AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.hintText),
        filled: isLight,
        fillColor: isLight ? AppColors.lightInputBackground : Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isLight ? AppColors.lightBorder : const Color(0xFF2C313C),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}
