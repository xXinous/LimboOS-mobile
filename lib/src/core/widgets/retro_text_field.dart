import 'package:flutter/material.dart';
import '../theme.dart';

class RetroTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final Widget? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const RetroTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: RetroTheme.kSurfaceContainerLowest,
            border: Border(
              bottom: BorderSide(
                color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.2),
              ),
              prefixIcon: prefixIcon,
              prefixIconColor: RetroTheme.kIndustrialSilver.withValues(alpha: 0.4),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
