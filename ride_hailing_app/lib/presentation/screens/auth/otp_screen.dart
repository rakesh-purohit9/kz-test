import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/widgets.dart';

/// OTP verification screen
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendCountdown = 30;
  bool _canResend = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _canResend = false;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _otp {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 4) {
      setState(() {
        _errorText = 'Please enter the complete code';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final success = await ref.read(authProvider.notifier).verifyOtp(_otp);

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        setState(() {
          _errorText = 'Invalid verification code. Please try again.';
        });
        // Clear inputs
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    final phoneNumber = ref.read(authProvider).phoneNumber;
    if (phoneNumber != null) {
      await ref.read(authProvider.notifier).sendOtp(phoneNumber);
      _startResendTimer();
    }
  }

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorText = null;
    });

    if (value.isNotEmpty && index < 3) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when complete
    if (_otp.length == 4) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // Move to previous field
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final phoneNumber = authState.phoneNumber ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(authProvider.notifier).resetOtpState();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Header
              Text(
                AppStrings.verifyPhone,
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${AppStrings.enterCode}\n$phoneNumber',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return _OtpDigitField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    hasError: _errorText != null,
                    onChanged: (value) => _onDigitChanged(index, value),
                    onKeyEvent: (event) => _onKeyPressed(index, event),
                  );
                }),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorText!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.didntReceive,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (_canResend)
                    GestureDetector(
                      onTap: _resendOtp,
                      child: Text(
                        AppStrings.resendCode,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // Verify Button
              PrimaryButton(
                text: 'Verify',
                onPressed: _verifyOtp,
                isLoading: isLoading,
                isEnabled: _otp.length == 4,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final Function(RawKeyEvent) onKeyEvent;

  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onKeyEvent,
      child: SizedBox(
        width: 64,
        height: 64,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTypography.displaySmall,
          cursorColor: AppColors.primary,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
