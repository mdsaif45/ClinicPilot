import 'package:flutter/material.dart';

// Reusable status and category pill badge
class CustomBadge extends StatelessWidget {
  final String label;
  final Color color;

  const CustomBadge({
    super.key,
    required this.label,
    this.color = const Color(0xFF0F5132),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
