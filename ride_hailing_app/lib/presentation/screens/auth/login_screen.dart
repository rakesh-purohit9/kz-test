import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/widgets.dart';

/// Login screen with phone number input
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+1';
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _phoneNumber {
    // Remove formatting from phone number
    return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool get _isValidPhone {
    return _phoneNumber.length == 10;
  }

  Future<void> _onContinue() async {
    if (!_isValidPhone) {
      setState(() {
        _errorText = 'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final fullNumber = '$_countryCode$_phoneNumber';
    await ref.read(authProvider.notifier).sendOtp(fullNumber);

    if (mounted) {
      context.push('/otp');
    }
  }

  void _showCountryPicker() {
    AppBottomSheet.show(
      context: context,
      child: _CountryCodePicker(
        selectedCode: _countryCode,
        onSelect: (code) {
          setState(() {
            _countryCode = code;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Header
              Text(
                AppStrings.getStarted,
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.enterPhone,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Phone Input
              PhoneTextField(
                controller: _phoneController,
                countryCode: _countryCode,
                onCountryCodeTap: _showCountryPicker,
                errorText: _errorText,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _errorText = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Terms Text
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Continue Button
              PrimaryButton(
                text: AppStrings.continueText,
                onPressed: _onContinue,
                isLoading: isLoading,
                isEnabled: _phoneNumber.isNotEmpty,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Social Login Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      AppStrings.orContinueWith,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Social Login Buttons
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onTap: () => context.go('/home'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Demo Skip Button
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Skip to Demo →',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _CountryCodePicker extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onSelect;

  const _CountryCodePicker({
    required this.selectedCode,
    required this.onSelect,
  });

  static const _countries = [
    ('+1', 'United States', '🇺🇸'),
    ('+1', 'Canada', '🇨🇦'),
    ('+44', 'United Kingdom', '🇬🇧'),
    ('+61', 'Australia', '🇦🇺'),
    ('+91', 'India', '🇮🇳'),
    ('+49', 'Germany', '🇩🇪'),
    ('+33', 'France', '🇫🇷'),
    ('+81', 'Japan', '🇯🇵'),
    ('+86', 'China', '🇨🇳'),
    ('+52', 'Mexico', '🇲🇽'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Select Country',
            style: AppTypography.headlineSmall,
          ),
        ),
        const Divider(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _countries.length,
          itemBuilder: (context, index) {
            final country = _countries[index];
            final isSelected = country.$1 == selectedCode;

            return ListTile(
              leading: Text(
                country.$3,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(country.$2),
              trailing: Text(
                country.$1,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onTap: () => onSelect(country.$1),
            );
          },
        ),
      ],
    );
  }
}
