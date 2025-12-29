import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

/// Card for ride option selection (Economy, Premium, XL)
class RideOptionCard extends StatelessWidget {
  final RideOptionModel option;
  final bool isSelected;
  final VoidCallback? onTap;

  const RideOptionCard({
    super.key,
    required this.option,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: option.isAvailable ? onTap : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Opacity(
            opacity: option.isAvailable ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Car Icon
                  _buildCarIcon(),
                  const SizedBox(width: AppSpacing.md),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              option.type.displayName,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _buildSeatsIndicator(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              option.etaDisplay,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              option.type.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        option.priceDisplay,
                        style: AppTypography.price,
                      ),
                      if (option.hasSurge) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${option.surgeMultiplier}x',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarIcon() {
    IconData iconData;
    Color bgColor;

    switch (option.type) {
      case RideType.economy:
        iconData = Icons.directions_car;
        bgColor = AppColors.economyBg;
        break;
      case RideType.premium:
        iconData = Icons.directions_car;
        bgColor = AppColors.premiumBg;
        break;
      case RideType.xl:
        iconData = Icons.airport_shuttle;
        bgColor = AppColors.xlBg;
        break;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Icon(
        iconData,
        size: 32,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSeatsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            '${option.type.seats}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact ride option for horizontal scrolling
class CompactRideOptionCard extends StatelessWidget {
  final RideOptionModel option;
  final bool isSelected;
  final VoidCallback? onTap;

  const CompactRideOptionCard({
    super.key,
    required this.option,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 100,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.type == RideType.xl
                      ? Icons.airport_shuttle
                      : Icons.directions_car,
                  size: 28,
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  option.type.displayName,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.priceDisplay,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary.withOpacity(0.8)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
