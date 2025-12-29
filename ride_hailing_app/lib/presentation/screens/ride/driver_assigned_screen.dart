import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

/// Driver assigned screen - shows driver info and ETA
class DriverAssignedScreen extends ConsumerStatefulWidget {
  const DriverAssignedScreen({super.key});

  @override
  ConsumerState<DriverAssignedScreen> createState() =>
      _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends ConsumerState<DriverAssignedScreen> {
  void _onCallDriver() {
    // In production, launch phone dialer
    _showActionSnackbar('Calling driver...');
  }

  void _onMessageDriver() {
    // In production, open messaging
    _showActionSnackbar('Opening messages...');
  }

  void _onShareTrip() {
    // In production, open share sheet
    _showActionSnackbar('Sharing trip details...');
  }

  void _onSafetyTap() {
    _showSafetySheet();
  }

  void _showActionSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSafetySheet() {
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
            subtitle: const Text('Let friends and family follow along'),
            onTap: () {
              Navigator.pop(context);
              _onShareTrip();
            },
          ),
          ListTile(
            leading: const Icon(Icons.emergency),
            title: const Text('Emergency assistance'),
            subtitle: const Text('Call 911 and share location'),
            onTap: () {
              Navigator.pop(context);
              _showActionSnackbar('Emergency assistance...');
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Report an issue'),
            subtitle: const Text('Let us know if something is wrong'),
            onTap: () {
              Navigator.pop(context);
              _showActionSnackbar('Report an issue...');
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Future<void> _cancelRide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text(
          'Your driver is on the way. Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(rideProvider.notifier).cancelRide();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  void _startTrip() {
    ref.read(rideProvider.notifier).startTrip();
    context.pushReplacement('/trip-progress');
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideProvider);
    final locationState = ref.watch(locationProvider);
    final driver = rideState.assignedDriver;
    final ride = rideState.currentRide;

    // Listen for state changes
    ref.listen(rideProvider, (previous, next) {
      if (next.flowState == RideFlowState.inProgress) {
        context.pushReplacement('/trip-progress');
      }
    });

    if (driver == null || ride == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final statusText = _getStatusText(rideState.flowState, rideState.driverEta);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map with driver location
          _MapWithDriver(
            pickup: locationState.pickupLocation,
            driverLocation: driver.currentLocation,
            flowState: rideState.flowState,
          ),
          // Top Status Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Back/Cancel
                  if (rideState.flowState != RideFlowState.driverArrived)
                    CircleIconButton(
                      icon: Icons.close,
                      onPressed: _cancelRide,
                    ),
                  const Spacer(),
                  // Safety Button
                  CircleIconButton(
                    icon: Icons.shield_outlined,
                    onPressed: _onSafetyTap,
                  ),
                ],
              ),
            ),
          ),
          // Bottom Sheet with driver info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: AppSpacing.sm),
                      width: AppSpacing.bottomSheetHandleWidth,
                      height: AppSpacing.bottomSheetHandleHeight,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusRound),
                      ),
                    ),
                  ),
                  // Status
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          statusText,
                          style: AppTypography.headlineSmall,
                        ),
                        if (rideState.driverEta != null &&
                            rideState.driverEta! > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${rideState.driverEta} ${AppStrings.minAway}',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(),
                  // Driver Card
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: DriverCard(
                      driver: driver,
                      etaMinutes: rideState.driverEta,
                      onCallTap: _onCallDriver,
                      onMessageTap: _onMessageDriver,
                    ),
                  ),
                  // Action Buttons
                  if (rideState.flowState == RideFlowState.driverArrived) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        MediaQuery.of(context).padding.bottom + AppSpacing.md,
                      ),
                      child: PrimaryButton(
                        text: 'I\'m in the car',
                        onPressed: _startTrip,
                      ),
                    ),
                  ] else ...[
                    // Share and other buttons
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        MediaQuery.of(context).padding.bottom + AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onShareTrip,
                              icon: const Icon(Icons.share, size: 18),
                              label: Text(AppStrings.shareTrip),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _cancelRide,
                              icon: const Icon(Icons.close, size: 18),
                              label: Text(AppStrings.cancel),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(RideFlowState flowState, int? eta) {
    switch (flowState) {
      case RideFlowState.driverAssigned:
        return AppStrings.driverOnWay;
      case RideFlowState.driverArriving:
        return AppStrings.arriving;
      case RideFlowState.driverArrived:
        return AppStrings.arrivedAtPickup;
      default:
        return AppStrings.driverOnWay;
    }
  }
}

class _MapWithDriver extends StatelessWidget {
  final LocationModel? pickup;
  final LocationModel? driverLocation;
  final RideFlowState flowState;

  const _MapWithDriver({
    this.pickup,
    this.driverLocation,
    required this.flowState,
  });

  @override
  Widget build(BuildContext context) {
    final driverProgress = flowState == RideFlowState.driverArrived
        ? 1.0
        : flowState == RideFlowState.driverArriving
            ? 0.8
            : 0.4;

    return Container(
      color: const Color(0xFFE8E4E0),
      child: CustomPaint(
        size: Size.infinite,
        painter: _DriverMapPainter(driverProgress: driverProgress),
      ),
    );
  }
}

class _DriverMapPainter extends CustomPainter {
  final double driverProgress;

  _DriverMapPainter({required this.driverProgress});

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

    // Driver path to pickup
    final pathPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final pickupPoint = Offset(size.width * 0.5, size.height * 0.35);
    final driverStartPoint = Offset(size.width * 0.2, size.height * 0.35);

    final path = Path();
    path.moveTo(driverStartPoint.dx, driverStartPoint.dy);
    path.lineTo(pickupPoint.dx, pickupPoint.dy);
    canvas.drawPath(path, pathPaint);

    // Current driver position
    final driverX = driverStartPoint.dx +
        (pickupPoint.dx - driverStartPoint.dx) * driverProgress;
    final driverPoint = Offset(driverX, size.height * 0.35);

    // Driver marker
    canvas.drawCircle(
      driverPoint,
      12,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      driverPoint,
      8,
      Paint()..color = AppColors.background,
    );

    // Car icon placeholder
    final iconPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(
      Rect.fromCenter(center: driverPoint, width: 10, height: 6),
      iconPaint,
    );

    // Pickup marker
    canvas.drawCircle(
      pickupPoint,
      10,
      Paint()..color = AppColors.userLocation,
    );
    canvas.drawCircle(
      pickupPoint,
      6,
      Paint()..color = AppColors.background,
    );
  }

  @override
  bool shouldRepaint(covariant _DriverMapPainter oldDelegate) {
    return oldDelegate.driverProgress != driverProgress;
  }
}
