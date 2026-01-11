import 'package:flutter/material.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool isRequired;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
    this.isRequired = false,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          autofocus: autofocus,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey500,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: IconTheme(
                      data: const IconThemeData(size: 20),
                      child: prefixIcon!,
                    ),
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.grey200,
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  vertical: maxLines! > 1 ? 16 : 0,
                  horizontal: prefixIcon != null ? 0 : 16,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey500),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey500),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey400),
            ),
            errorMaxLines: 2,
            counterText: '',
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: enabled ? AppColors.black : AppColors.grey600,
          ),
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
        ),
      ],
    );
  }
}