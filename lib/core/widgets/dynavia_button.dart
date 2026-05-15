import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum DynaviaButtonType { primary, danger, secondary, ghost }

class DynaviaButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final DynaviaButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const DynaviaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = DynaviaButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  State<DynaviaButton> createState() => _DynaviaButtonState();
}

class _DynaviaButtonState extends State<DynaviaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get backgroundColor {
    switch (widget.type) {
      case DynaviaButtonType.primary:
        return AppColors.primary;
      case DynaviaButtonType.danger:
        _pulseController.repeat(reverse: true);
        return AppColors.emergency1;
      case DynaviaButtonType.secondary:
        return AppColors.surface;
      case DynaviaButtonType.ghost:
        return Colors.transparent;
    }
  }

  Color get textColor {
    switch (widget.type) {
      case DynaviaButtonType.primary:
      case DynaviaButtonType.danger:
        return AppColors.white;
      case DynaviaButtonType.secondary:
        return AppColors.primary;
      case DynaviaButtonType.ghost:
        return AppColors.primary;
    }
  }

  BorderSide? get borderSide {
    switch (widget.type) {
      case DynaviaButtonType.primary:
      case DynaviaButtonType.danger:
        return null;
      case DynaviaButtonType.secondary:
        return const BorderSide(color: AppColors.primary, width: 2);
      case DynaviaButtonType.ghost:
        return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonContent = widget.isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          );

    Widget button = Container(
      width: widget.width ?? double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
        boxShadow: widget.type == DynaviaButtonType.danger
            ? [
                BoxShadow(
                  color: AppColors.emergency1.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(child: buttonContent),
        ),
      ),
    );

    if (widget.type == DynaviaButtonType.danger) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: button,
      );
    }

    return button;
  }
}
