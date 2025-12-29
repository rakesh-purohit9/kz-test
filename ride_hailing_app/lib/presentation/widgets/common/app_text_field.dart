import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';

/// Custom text field following Uber design
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int maxLines;
  final FocusNode? focusNode;
  final bool readOnly;
  final EdgeInsets? contentPadding;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
    this.readOnly = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTap: onTap,
          onSubmitted: onSubmitted,
          maxLength: maxLength,
          maxLines: maxLines,
          focusNode: focusNode,
          readOnly: readOnly,
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? AppSpacing.inputPadding,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// Phone number input field with country code
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String countryCode;
  final VoidCallback? onCountryCodeTap;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool autofocus;
  final FocusNode? focusNode;

  const PhoneTextField({
    super.key,
    this.controller,
    this.countryCode = '+1',
    this.onCountryCodeTap,
    this.onChanged,
    this.errorText,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // Country Code Button
              InkWell(
                onTap: onCountryCodeTap,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppDimensions.radiusSm),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        countryCode,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: AppDimensions.iconSm,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              // Phone Number Input
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onChanged: onChanged,
                  style: AppTypography.bodyLarge,
                  cursorColor: AppColors.primary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    _PhoneNumberFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: '(555) 123-4567',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Phone number formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 0) buffer.write('(');
      buffer.write(text[i]);
      if (i == 2) buffer.write(') ');
      if (i == 5) buffer.write('-');
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Search text field with Uber-style design
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool readOnly;
  final FocusNode? focusNode;
  final Widget? leading;
  final Widget? trailing;

  const SearchTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
    this.focusNode,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            const SizedBox(width: AppSpacing.md),
            leading!,
          ],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: AppTypography.bodyLarge,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.searchHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
