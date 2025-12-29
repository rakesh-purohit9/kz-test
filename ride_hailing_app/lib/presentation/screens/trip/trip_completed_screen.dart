import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

/// Trip completed screen with rating and tip
class TripCompletedScreen extends ConsumerStatefulWidget {
  const TripCompletedScreen({super.key});

  @override
  ConsumerState<TripCompletedScreen> createState() =>
      _TripCompletedScreenState();
}

class _TripCompletedScreenState extends ConsumerState<TripCompletedScreen> {
  int _rating = 5;
  int? _selectedTip;
  final _feedbackController = TextEditingController();
  bool _showFareBreakdown = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    ref.read(rideProvider.notifier).rateRide(rating);
  }

  void _setTip(int? amount) {
    setState(() {
      _selectedTip = amount;
    });
    ref.read(rideProvider.notifier).selectTip(amount);
  }

  void _toggleFareBreakdown() {
    setState(() {
      _showFareBreakdown = !_showFareBreakdown;
    });
  }

  Future<void> _submitAndClose() async {
    if (_feedbackController.text.isNotEmpty) {
      ref.read(rideProvider.notifier).submitFeedback(_feedbackController.text);
    }

    await ref.read(rideProvider.notifier).submitRating();
    ref.read(rideProvider.notifier).reset();

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideProvider);
    final ride = rideState.currentRide;
    final driver = rideState.assignedDriver;
    final fareBreakdown = rideState.fareBreakdown;

    if (ride == null || driver == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textOnPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Thank you message
              Text(
                AppStrings.thankYou,
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.howWasTrip,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Driver Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.divider,
                    backgroundImage: driver.photoUrl.isNotEmpty
                        ? NetworkImage(driver.photoUrl)
                        : null,
                    child: driver.photoUrl.isEmpty
                        ? Text(
                            driver.initials,
                            style: AppTypography.titleLarge,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        driver.vehicle.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () => _setRating(starIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= _rating
                            ? Icons.star
                            : Icons.star_border,
                        size: 40,
                        color: starIndex <= _rating
                            ? Colors.amber
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Fare Card
              _FareCard(
                ride: ride,
                fareBreakdown: fareBreakdown,
                isExpanded: _showFareBreakdown,
                onToggle: _toggleFareBreakdown,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Tip Section
              _TipSection(
                selectedTip: _selectedTip,
                onSelectTip: _setTip,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Feedback Input
              if (_rating < 4) ...[
                AppTextField(
                  controller: _feedbackController,
                  hintText: 'What could have been better?',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              // Done Button
              PrimaryButton(
                text: AppStrings.done,
                onPressed: _submitAndClose,
                isLoading: rideState.isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FareCard extends StatelessWidget {
  final RideModel ride;
  final FareBreakdown? fareBreakdown;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FareCard({
    required this.ride,
    this.fareBreakdown,
    required this.isExpanded,
    required this.onToggle,
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
        children: [
          // Total
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    AppStrings.total,
                    style: AppTypography.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    ride.actualFareDisplay,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Breakdown
          if (isExpanded && fareBreakdown != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _FareRow(
                    label: AppStrings.baseFare,
                    amount: fareBreakdown!.formatAmount(fareBreakdown!.baseFare),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FareRow(
                    label: AppStrings.distance,
                    amount: fareBreakdown!.formatAmount(fareBreakdown!.distanceFare),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FareRow(
                    label: AppStrings.time,
                    amount: fareBreakdown!.formatAmount(fareBreakdown!.timeFare),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FareRow(
                    label: AppStrings.serviceFee,
                    amount: fareBreakdown!.formatAmount(fareBreakdown!.serviceFee),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String amount;

  const _FareRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}

class _TipSection extends StatelessWidget {
  final int? selectedTip;
  final ValueChanged<int?> onSelectTip;

  const _TipSection({
    this.selectedTip,
    required this.onSelectTip,
  });

  static const _tipAmounts = [0, 2, 5, 10];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.addTip,
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: _tipAmounts.map((amount) {
            final isSelected = selectedTip == amount;
            final label = amount == 0 ? AppStrings.noTip : '\$$amount';

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: amount != _tipAmounts.last ? AppSpacing.sm : 0,
                ),
                child: _TipButton(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => onSelectTip(amount == 0 ? null : amount),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
