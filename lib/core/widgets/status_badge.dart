import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StatusBadge extends StatefulWidget {
  final int level;
  final String text;
  final bool showAnimation;

  const StatusBadge({
    super.key,
    required this.level,
    required this.text,
    this.showAnimation = true,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.showAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get backgroundColor => AppColors.getEmergencyColor(widget.level);
  Color get backgroundTint => AppColors.getEmergencyBackgroundColor(widget.level);

  String get levelText {
    switch (widget.level) {
      case 1:
        return 'CRÍTICO';
      case 2:
        return 'URGENTE';
      case 3:
        return 'PREVENTIVO';
      default:
        return 'NIVEL ${widget.level}';
    }
  }

  IconData get levelIcon {
    switch (widget.level) {
      case 1:
        return Icons.warning_rounded;
      case 2:
        return Icons.priority_high_rounded;
      case 3:
        return Icons.info_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: backgroundColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showAnimation) ...[
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(levelIcon, color: backgroundColor, size: 18),
          const SizedBox(width: 6),
          Text(
            levelText,
            style: AppTypography.labelLarge.copyWith(
              color: backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.text.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              '• ${widget.text}',
              style: AppTypography.labelMedium.copyWith(
                color: backgroundColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
