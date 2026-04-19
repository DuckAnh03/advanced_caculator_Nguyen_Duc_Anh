import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

enum ButtonType { number, operator, function, equals, memory, clear }

class CalculatorButton extends StatefulWidget {
  final String label;
  final String? subLabel; // shown when shift is active
  final ButtonType type;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isWide; // spans 2 columns
  final bool isActive; // e.g. shift button highlighted
  final double fontSize;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.subLabel,
    this.onLongPress,
    this.isWide = false,
    this.isActive = false,
    this.fontSize = 18,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimens.buttonPressDuration,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  // ─── Colors ─────────────────────────────────────────────────────────────

  Color _bgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.isActive) {
      return isDark ? AppColors.darkAccent : AppColors.lightAccent;
    }
    switch (widget.type) {
      case ButtonType.equals:
        return isDark ? AppColors.equalsDark : AppColors.equalsLight;
      case ButtonType.operator:
        return isDark
            ? AppColors.operatorDark.withOpacity(0.2)
            : AppColors.operatorLight.withOpacity(0.15);
      case ButtonType.function:
        return isDark ? AppColors.functionDark : AppColors.functionLight;
      case ButtonType.memory:
        return isDark ? const Color(0xFF1A3A3A) : const Color(0xFFE8F5E9);
      case ButtonType.clear:
        return isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFEBEE);
      case ButtonType.number:
        return isDark ? AppColors.numberDark : AppColors.numberLight;
    }
  }

  Color _textColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.isActive) return Colors.white;
    switch (widget.type) {
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.operator:
        return isDark ? AppColors.darkAccent : AppColors.lightAccent;
      case ButtonType.clear:
        return isDark ? const Color(0xFFEF9A9A) : const Color(0xFFD32F2F);
      case ButtonType.memory:
        return isDark ? AppColors.darkAccent : const Color(0xFF2E7D32);
      case ButtonType.function:
      case ButtonType.number:
        return isDark ? AppColors.darkText : AppColors.lightText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor(context),
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.subLabel != null)
                Text(
                  widget.subLabel!,
                  style: TextStyle(
                    fontSize: 9,
                    color: _textColor(context).withOpacity(0.6),
                    fontFamily: AppFonts.family,
                  ),
                ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: widget.type == ButtonType.equals
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _textColor(context),
                  fontFamily: AppFonts.family,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
