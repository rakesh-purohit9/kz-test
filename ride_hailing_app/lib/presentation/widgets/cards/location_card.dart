import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';

/// Card for displaying a location item
class LocationCard extends StatelessWidget {
  final LocationModel location;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const LocationCard({
    super.key,
    required this.location,
    this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          children: [
            leading ??
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name ?? location.shortAddress,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      location.address!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Saved place card (Home, Work)
class SavedPlaceCard extends StatelessWidget {
  final SavedPlace place;
  final VoidCallback? onTap;

  const SavedPlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData iconData;
    switch (place.type) {
      case SavedPlaceType.home:
        iconData = Icons.home_outlined;
        break;
      case SavedPlaceType.work:
        iconData = Icons.work_outline;
        break;
      case SavedPlaceType.other:
        iconData = Icons.star_outline;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(
                iconData,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.isSet
                        ? place.location!.shortAddress
                        : 'Add ${place.name.toLowerCase()}',
                    style: AppTypography.bodySmall.copyWith(
                      color: place.isSet
                          ? AppColors.textSecondary
                          : AppColors.info,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              place.isSet ? Icons.chevron_right : Icons.add,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent location item
class RecentLocationItem extends StatelessWidget {
  final RecentPlace recentPlace;
  final VoidCallback? onTap;

  const RecentLocationItem({
    super.key,
    required this.recentPlace,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recentPlace.location.name ?? recentPlace.location.shortAddress,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recentPlace.location.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      recentPlace.location.address!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pickup/Dropoff location indicator
class LocationIndicator extends StatelessWidget {
  final bool isPickup;
  final String? label;
  final String address;
  final VoidCallback? onTap;

  const LocationIndicator({
    super.key,
    required this.isPickup,
    this.label,
    required this.address,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isPickup ? AppColors.textPrimary : AppColors.textPrimary,
                shape: isPickup ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isPickup ? null : BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null) ...[
                    Text(
                      label!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    address,
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route summary showing pickup and destination
class RouteCard extends StatelessWidget {
  final LocationModel pickup;
  final LocationModel destination;
  final VoidCallback? onPickupTap;
  final VoidCallback? onDestinationTap;

  const RouteCard({
    super.key,
    required this.pickup,
    required this.destination,
    this.onPickupTap,
    this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          LocationIndicator(
            isPickup: true,
            label: 'Pickup',
            address: pickup.shortAddress,
            onTap: onPickupTap,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 22),
            child: Divider(indent: AppSpacing.md),
          ),
          LocationIndicator(
            isPickup: false,
            label: 'Dropoff',
            address: destination.shortAddress,
            onTap: onDestinationTap,
          ),
        ],
      ),
    );
  }
}
