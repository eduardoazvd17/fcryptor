import 'package:flutter/material.dart';

class RoundedIconWidget extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const RoundedIconWidget({
    required this.icon,
    this.color,
    this.size = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (color ?? Theme.of(context).colorScheme.primary)
            .withValues(alpha: 0.1),
      ),
      child: Icon(
        icon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
