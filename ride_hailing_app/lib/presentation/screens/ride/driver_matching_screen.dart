import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/widgets.dart';

/// Driver matching/searching screen
class DriverMatchingScreen extends ConsumerStatefulWidget {
  const DriverMatchingScreen({super.key});

  @override
  ConsumerState<DriverMatchingScreen> createState() =>
      _DriverMatchingScreenState();
}

class _DriverMatchingScreenState extends ConsumerState<DriverMatchingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.searchingPulse,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _cancelRide() async {
    final confirmed = await _showCancelConfirmation();
    if (confirmed == true) {
      await ref.read(rideProvider.notifier).cancelRide();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<bool?> _showCancelConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text(
          'Are you sure you want to cancel this ride request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideProvider);

    // Navigate when driver is assigned
    ref.listen(rideProvider, (previous, next) {
      if (next.flowState == RideFlowState.driverAssigned) {
        context.pushReplacement('/driver-assigned');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Map Background
          _AnimatedMapView(
            rotationController: _rotationController,
          ),
          // Searching Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0.3),
                  AppColors.background.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Pulsing Search Animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppColors.textOnPrimary,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Status Text
                Text(
                  AppStrings.findingRide,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.lookingForDrivers,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Loading Dots
                _LoadingDots(),
                const Spacer(flex: 3),
                // Cancel Button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                  ),
                  child: SecondaryButton(
                    text: AppStrings.cancel,
                    onPressed: _cancelRide,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMapView extends StatelessWidget {
  final AnimationController rotationController;

  const _AnimatedMapView({required this.rotationController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E4E0),
      child: Stack(
        children: [
          // Map grid
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          // Animated cars
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: rotationController,
              builder: (context, child) {
                final angle = rotationController.value * 2 * pi + (index * pi / 1.5);
                final radius = 100.0 + (index * 30);
                final centerX = MediaQuery.of(context).size.width / 2;
                final centerY = MediaQuery.of(context).size.height / 3;

                return Positioned(
                  left: centerX + cos(angle) * radius - 15,
                  top: centerY + sin(angle) * radius - 15,
                  child: Transform.rotate(
                    angle: angle + pi / 2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.textOnPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Roads
    final roadPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 8;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height * 0.7),
      roadPaint..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value + delay) % 1.0;
            final opacity = sin(value * pi);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
