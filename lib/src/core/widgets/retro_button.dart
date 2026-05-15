import 'package:flutter/material.dart';
import '../theme.dart';

class RetroButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final Color? color;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: color ?? RetroTheme.kPrimary,
            boxShadow: [
              BoxShadow(
                color: (color ?? RetroTheme.kPrimary).withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              else if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color == null ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
