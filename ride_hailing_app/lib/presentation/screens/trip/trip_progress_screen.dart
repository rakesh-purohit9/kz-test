import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

/// Trip in progress screen
class TripProgressScreen extends ConsumerStatefulWidget {
  const TripProgressScreen({super.key});

  @override
  ConsumerState<TripProgressScreen> createState() => _TripProgressScreenState();
}

class _TripProgressScreenState extends ConsumerState<TripProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  void _onSafetyTap() {
    AppBottomSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              AppStrings.safetyTools,
              style: AppTypography.headlineSmall,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share_location),
            title: const Text('Share my trip'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.emergency),
            title: const Text('Emergency assistance'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Report safety issue'),
            onTap: () => Navigator.pop(context),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideProvider);
    final locationState = ref.watch(locationProvider);
    final ride = rideState.currentRide;
    final driver = rideState.assignedDriver;

    // Listen for trip completion
    ref.listen(rideProvider, (previous, next) {
      if (next.flowState == RideFlowState.completed) {
        context.pushReplacement('/trip-completed');
      }
    });

    if (ride == null || driver == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Map
          _AnimatedTripMap(
            pickup: locationState.pickupLocation,
            destination: locationState.destinationLocation,
            progressController: _progressController,
          ),
          // Safety Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleIconButton(
                  icon: Icons.shield_outlined,
                  onPressed: _onSafetyTap,
                ),
              ),
            ),
          ),
          // Bottom Info Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: AppDurations.normal,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.bottomSheetTopRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlayLight,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  GestureDetector(
                    onTap: _toggleDetails,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Column(
                        children: [
                          Container(
                            width: AppSpacing.bottomSheetHandleWidth,
                            height: AppSpacing.bottomSheetHandleHeight,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusRound),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.enRoute,
                                style: AppTypography.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${AppStrings.arrivingAt} ${ride.estimatedDurationMinutes} min',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _showDetails
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                          ),
                          onPressed: _toggleDetails,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Destination
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.divider.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              locationState.destinationLocation?.shortAddress ??
                                  'Destination',
                              style: AppTypography.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expanded Details
                  if (_showDetails) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    // Driver Info
                    CompactDriverInfo(
                      driver: driver,
                      onTap: () {
                        // Show full driver info
                      },
                    ),
                    const Divider(),
                    // Trip Details
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TripDetailItem(
                            label: 'Distance',
                            value: ride.distanceDisplay,
                          ),
                          _TripDetailItem(
                            label: 'Time',
                            value: ride.durationDisplay,
                          ),
                          _TripDetailItem(
                            label: 'Fare',
                            value: ride.fareDisplay,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + AppSpacing.md,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _TripDetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
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

class _AnimatedTripMap extends StatelessWidget {
  final LocationModel? pickup;
  final LocationModel? destination;
  final AnimationController progressController;

  const _AnimatedTripMap({
    this.pickup,
    this.destination,
    required this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E4E0),
      child: AnimatedBuilder(
        animation: progressController,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _TripMapPainter(progress: progressController.value),
          );
        },
      ),
    );
  }
}

class _TripMapPainter extends CustomPainter {
  final double progress;

  _TripMapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Background grid
    final gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Roads
    final roadPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 8;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.35),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );

    // Route
    final pickupPoint = Offset(size.width * 0.2, size.height * 0.35);
    final midPoint = Offset(size.width * 0.5, size.height * 0.35);
    final destPoint = Offset(size.width * 0.5, size.height * 0.15);

    // Completed route (highlighted)
    final completedPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Remaining route (faded)
    final remainingPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw routes
    final totalDistance = (midPoint.dx - pickupPoint.dx) +
        (midPoint.dy - destPoint.dy);
    final currentDistance = totalDistance * progress;

    // First segment
    final firstSegmentLength = midPoint.dx - pickupPoint.dx;
    if (currentDistance < firstSegmentLength) {
      // Partially on first segment
      final segmentProgress = currentDistance / firstSegmentLength;
      final currentX = pickupPoint.dx + (midPoint.dx - pickupPoint.dx) * segmentProgress;

      canvas.drawLine(pickupPoint, Offset(currentX, pickupPoint.dy), completedPaint);
      canvas.drawLine(Offset(currentX, midPoint.dy), midPoint, remainingPaint);
      canvas.drawLine(midPoint, destPoint, remainingPaint);
    } else {
      // Completed first segment, on second
      canvas.drawLine(pickupPoint, midPoint, completedPaint);

      final secondSegmentProgress =
          (currentDistance - firstSegmentLength) / (midPoint.dy - destPoint.dy);
      final currentY = midPoint.dy - (midPoint.dy - destPoint.dy) * secondSegmentProgress;

      canvas.drawLine(midPoint, Offset(midPoint.dx, currentY), completedPaint);
      canvas.drawLine(Offset(midPoint.dx, currentY), destPoint, remainingPaint);
    }

    // Car position
    Offset carPosition;
    double carAngle;

    if (currentDistance < firstSegmentLength) {
      final segmentProgress = currentDistance / firstSegmentLength;
      carPosition = Offset(
        pickupPoint.dx + (midPoint.dx - pickupPoint.dx) * segmentProgress,
        pickupPoint.dy,
      );
      carAngle = 0;
    } else {
      final secondSegmentProgress =
          (currentDistance - firstSegmentLength) / (midPoint.dy - destPoint.dy);
      carPosition = Offset(
        midPoint.dx,
        midPoint.dy - (midPoint.dy - destPoint.dy) * secondSegmentProgress,
      );
      carAngle = -pi / 2;
    }

    // Draw car
    canvas.save();
    canvas.translate(carPosition.dx, carPosition.dy);
    canvas.rotate(carAngle);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -6, 24, 12),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.primary,
    );

    canvas.restore();

    // Pickup marker (faded)
    canvas.drawCircle(
      pickupPoint,
      8,
      Paint()..color = AppColors.textSecondary.withOpacity(0.5),
    );

    // Destination marker
    canvas.drawRect(
      Rect.fromCenter(center: destPoint, width: 12, height: 12),
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _TripMapPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
