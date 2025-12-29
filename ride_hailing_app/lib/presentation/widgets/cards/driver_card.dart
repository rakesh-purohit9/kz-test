import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

/// Card displaying driver information
class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final int? etaMinutes;
  final VoidCallback? onCallTap;
  final VoidCallback? onMessageTap;

  const DriverCard({
    super.key,
    required this.driver,
    this.etaMinutes,
    this.onCallTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Driver Info Row
          Row(
            children: [
              // Driver Photo
              _buildDriverPhoto(),
              const SizedBox(width: AppSpacing.md),
              // Driver Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.firstName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver.ratingDisplay,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${driver.totalTrips} trips',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Contact Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ContactButton(
                    icon: Icons.message_outlined,
                    onTap: onMessageTap,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ContactButton(
                    icon: Icons.phone_outlined,
                    onTap: onCallTap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          // Vehicle Info Row
          Row(
            children: [
              // Vehicle Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.economyBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Vehicle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.vehicle.displayName,
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${driver.vehicle.color} · ${driver.vehicle.licensePlate}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // License Plate Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  driver.vehicle.licensePlate,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (etaMinutes != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Arriving in $etaMinutes min',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDriverPhoto() {
    return Container(
      width: AppDimensions.avatarLg,
      height: AppDimensions.avatarLg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.divider,
        image: driver.photoUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(driver.photoUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: driver.photoUrl.isEmpty
          ? Center(
              child: Text(
                driver.initials,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : null,
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ContactButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.divider,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Compact driver info for trip progress
class CompactDriverInfo extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback? onTap;

  const CompactDriverInfo({
    super.key,
    required this.driver,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.divider,
              backgroundImage: driver.photoUrl.isNotEmpty
                  ? NetworkImage(driver.photoUrl)
                  : null,
              child: driver.photoUrl.isEmpty
                  ? Text(
                      driver.initials,
                      style: AppTypography.labelMedium,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.firstName,
                    style: AppTypography.titleSmall,
                  ),
                  Text(
                    driver.vehicle.licensePlate,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
