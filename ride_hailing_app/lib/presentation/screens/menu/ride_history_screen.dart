import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';

/// Ride history screen
class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rides = ref.watch(rideHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.rideHistory),
      ),
      body: rides.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return _RideHistoryItem(ride: rides[index]);
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No trips yet',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your ride history will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RideHistoryItem extends StatelessWidget {
  final RideModel ride;

  const _RideHistoryItem({required this.ride});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return InkWell(
      onTap: () {
        // Show ride details
        _showRideDetails(context);
      },
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car type icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(
                ride.rideType == RideType.xl
                    ? Icons.airport_shuttle
                    : Icons.directions_car,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Ride details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.destination.name ?? ride.destination.shortAddress,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormat.format(ride.createdAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ride.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ride.status.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: _getStatusColor(ride.status),
                          ),
                        ),
                      ),
                      if (ride.rating != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${ride.rating}',
                              style: AppTypography.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Fare
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ride.actualFareDisplay,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  ride.rideType.displayName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return AppColors.success;
      case RideStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  void _showRideDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.bottomSheetTopRadius),
        ),
      ),
      builder: (context) => _RideDetailsSheet(ride: ride),
    );
  }
}

class _RideDetailsSheet extends StatelessWidget {
  final RideModel ride;

  const _RideDetailsSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: AppSpacing.bottomSheetHandleWidth,
                  height: AppSpacing.bottomSheetHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Date and Type
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(ride.createdAt),
                          style: AppTypography.titleMedium,
                        ),
                        Text(
                          ride.rideType.displayName,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ride.actualFareDisplay,
                    style: AppTypography.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              // Route
              _RouteItem(
                isPickup: true,
                address: ride.pickup.address ?? '',
                time: ride.pickupTime != null
                    ? timeFormat.format(ride.pickupTime!)
                    : null,
              ),
              Container(
                margin: const EdgeInsets.only(left: 4),
                height: 24,
                width: 2,
                color: AppColors.divider,
              ),
              _RouteItem(
                isPickup: false,
                address: ride.destination.address ?? '',
                time: ride.dropoffTime != null
                    ? timeFormat.format(ride.dropoffTime!)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              // Trip Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Distance',
                    value: ride.distanceDisplay,
                  ),
                  _StatItem(
                    label: 'Duration',
                    value: ride.durationDisplay,
                  ),
                  if (ride.rating != null)
                    _StatItem(
                      label: 'Rating',
                      value: '${ride.rating}/5',
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Driver info (if available)
              if (ride.driver != null) ...[
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Driver',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.divider,
                      backgroundImage: ride.driver!.photoUrl.isNotEmpty
                          ? NetworkImage(ride.driver!.photoUrl)
                          : null,
                      child: ride.driver!.photoUrl.isEmpty
                          ? Text(ride.driver!.initials)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driver!.fullName,
                            style: AppTypography.titleSmall,
                          ),
                          Text(
                            ride.driver!.vehicle.displayName,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          ride.driver!.ratingDisplay,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _RouteItem extends StatelessWidget {
  final bool isPickup;
  final String address;
  final String? time;

  const _RouteItem({
    required this.isPickup,
    required this.address,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: isPickup ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isPickup ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: AppTypography.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (time != null) ...[
                const SizedBox(height: 2),
                Text(
                  time!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
