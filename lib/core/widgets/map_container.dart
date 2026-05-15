import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MapContainer extends StatelessWidget {
  final Widget child;
  final bool showBorder;
  final double borderRadius;

  const MapContainer({
    super.key,
    required this.child,
    this.showBorder = true,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: showBorder
            ? BorderRadius.circular(borderRadius)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: showBorder
            ? BorderRadius.circular(borderRadius)
            : BorderRadius.zero,
        child: child,
      ),
    );
  }
}
