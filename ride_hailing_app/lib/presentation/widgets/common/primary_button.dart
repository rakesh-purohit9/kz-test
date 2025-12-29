import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

/// Primary full-width button following Uber design
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = textColor ?? AppColors.textOnPrimary;
    final isActive = isEnabled && !isLoading && onPressed != null;

    return AnimatedContainer(
      duration: AppDurations.fast,
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeightLg,
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? bgColor : bgColor.withOpacity(0.5),
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor.withOpacity(0.5),
            disabledForegroundColor: fgColor.withOpacity(0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      text,
                      style: AppTypography.button.copyWith(color: fgColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightMd,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Icon button with circular background
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double elevation;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shape: const CircleBorder(),
      color: backgroundColor ?? AppColors.background,
      shadowColor: AppColors.overlayLight,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
