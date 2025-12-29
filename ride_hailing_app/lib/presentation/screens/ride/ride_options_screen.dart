import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

/// Ride options selection screen
class RideOptionsScreen extends ConsumerStatefulWidget {
  const RideOptionsScreen({super.key});

  @override
  ConsumerState<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends ConsumerState<RideOptionsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRideOptions();
  }

  void _fetchRideOptions() {
    final locationState = ref.read(locationProvider);
    if (locationState.pickupLocation != null &&
        locationState.destinationLocation != null) {
      ref.read(rideProvider.notifier).getRideOptions(
            pickup: locationState.pickupLocation!,
            destination: locationState.destinationLocation!,
          );
    }
  }

  void _onRideTypeSelected(RideType type) {
    ref.read(rideProvider.notifier).selectRideType(type);
  }

  void _onPaymentTap() {
    _showPaymentMethodPicker();
  }

  void _showPaymentMethodPicker() {
    AppBottomSheet.show(
      context: context,
      child: _PaymentMethodPicker(
        selectedMethod: ref.read(rideProvider).paymentMethod,
        onSelect: (method) {
          ref.read(rideProvider.notifier).setPaymentMethod(method);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _onConfirmRide() async {
    final locationState = ref.read(locationProvider);
    if (locationState.pickupLocation == null ||
        locationState.destinationLocation == null) {
      return;
    }

    await ref.read(rideProvider.notifier).requestRide(
          pickup: locationState.pickupLocation!,
          destination: locationState.destinationLocation!,
        );

    if (mounted) {
      context.pushReplacement('/driver-matching');
    }
  }

  void _onEditRoute() {
    ref.read(locationProvider.notifier).clearDestination();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final rideState = ref.watch(rideProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map with route
          _MapWithRoute(
            pickup: locationState.pickupLocation,
            destination: locationState.destinationLocation,
          ),
          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CircleIconButton(
                icon: Icons.arrow_back,
                onPressed: _onEditRoute,
              ),
            ),
          ),
          // Bottom Sheet with ride options
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _RideOptionsSheet(
              pickup: locationState.pickupLocation,
              destination: locationState.destinationLocation,
              rideOptions: rideState.rideOptions,
              selectedRideType: rideState.selectedRideType,
              paymentMethod: rideState.paymentMethod,
              isLoading: rideState.isLoading,
              onRideTypeSelected: _onRideTypeSelected,
              onPaymentTap: _onPaymentTap,
              onConfirmRide: _onConfirmRide,
              onEditRoute: _onEditRoute,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapWithRoute extends StatelessWidget {
  final LocationModel? pickup;
  final LocationModel? destination;

  const _MapWithRoute({
    this.pickup,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E4E0),
      child: CustomPaint(
        size: Size.infinite,
        painter: _RouteMapPainter(
          hasRoute: pickup != null && destination != null,
        ),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final bool hasRoute;

  _RouteMapPainter({required this.hasRoute});

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
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );

    if (hasRoute) {
      // Route line
      final routePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.3, size.height * 0.35);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.5,
        size.height * 0.25,
      );
      path.lineTo(size.width * 0.5, size.height * 0.15);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.7,
        size.height * 0.1,
      );

      canvas.drawPath(path, routePaint);

      // Pickup marker
      final pickupCenter = Offset(size.width * 0.3, size.height * 0.35);
      canvas.drawCircle(
        pickupCenter,
        8,
        Paint()..color = AppColors.primary,
      );
      canvas.drawCircle(
        pickupCenter,
        5,
        Paint()..color = AppColors.background,
      );

      // Destination marker
      final destCenter = Offset(size.width * 0.7, size.height * 0.1);
      canvas.drawRect(
        Rect.fromCenter(center: destCenter, width: 12, height: 12),
        Paint()..color = AppColors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) {
    return oldDelegate.hasRoute != hasRoute;
  }
}

class _RideOptionsSheet extends StatelessWidget {
  final LocationModel? pickup;
  final LocationModel? destination;
  final List<RideOptionModel> rideOptions;
  final RideType? selectedRideType;
  final PaymentMethod paymentMethod;
  final bool isLoading;
  final ValueChanged<RideType> onRideTypeSelected;
  final VoidCallback onPaymentTap;
  final VoidCallback onConfirmRide;
  final VoidCallback onEditRoute;

  const _RideOptionsSheet({
    required this.pickup,
    required this.destination,
    required this.rideOptions,
    required this.selectedRideType,
    required this.paymentMethod,
    required this.isLoading,
    required this.onRideTypeSelected,
    required this.onPaymentTap,
    required this.onConfirmRide,
    required this.onEditRoute,
  });

  RideOptionModel? get selectedOption {
    if (selectedRideType == null || rideOptions.isEmpty) return null;
    return rideOptions.firstWhere(
      (o) => o.type == selectedRideType,
      orElse: () => rideOptions.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
            ),
          ),
          // Route Summary
          if (pickup != null && destination != null) ...[
            InkWell(
              onTap: onEditRoute,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _RoutePoint(
                            isPickup: true,
                            address: pickup!.shortAddress,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _RoutePoint(
                            isPickup: false,
                            address: destination!.shortAddress,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
          ],
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.chooseRide,
                  style: AppTypography.headlineSmall,
                ),
                const Spacer(),
                if (selectedOption != null)
                  Text(
                    '${selectedOption!.durationDisplay} trip',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Ride Options
          if (isLoading && rideOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: rideOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final option = rideOptions[index];
                return RideOptionCard(
                  option: option,
                  isSelected: option.type == selectedRideType,
                  onTap: () => onRideTypeSelected(option.type),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          // Payment Method
          InkWell(
            onTap: onPaymentTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    paymentMethod == PaymentMethod.cash
                        ? Icons.money
                        : Icons.credit_card,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    paymentMethod.displayName,
                    style: AppTypography.bodyMedium,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Confirm Button
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            child: PrimaryButton(
              text: selectedOption != null
                  ? '${AppStrings.confirmRide} ${selectedOption!.type.displayName} - ${selectedOption!.priceDisplay}'
                  : AppStrings.confirmRide,
              onPressed: selectedOption != null ? onConfirmRide : null,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final bool isPickup;
  final String address;

  const _RoutePoint({
    required this.isPickup,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: isPickup ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isPickup ? null : BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            address,
            style: AppTypography.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodPicker extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onSelect;

  const _PaymentMethodPicker({
    required this.selectedMethod,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            AppStrings.paymentMethod,
            style: AppTypography.headlineSmall,
          ),
        ),
        const Divider(),
        ...PaymentMethod.values.map((method) {
          final isSelected = method == selectedMethod;
          return ListTile(
            leading: Icon(
              method == PaymentMethod.cash ? Icons.money : Icons.credit_card,
              color: AppColors.textPrimary,
            ),
            title: Text(method.displayName),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.success)
                : null,
            onTap: () => onSelect(method),
          );
        }),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
