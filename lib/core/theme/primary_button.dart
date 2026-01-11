import 'package:flutter/material.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.fullWidth = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.grey500,
          disabledForegroundColor: AppColors.grey300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor ?? AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: foregroundColor ?? AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Secondary button variant
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool fullWidth;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fullWidth = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Pre-configured buttons for specific use cases
class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool fullWidth;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: isLoading ? 'Memproses...' : 'Masuk',
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: Icons.login,
    );
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool fullWidth;

  const RegisterButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: isLoading ? 'Mendaftarkan...' : 'Daftar',
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: Icons.person_add,
    );
  }
}

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool fullWidth;
  final String? customText;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: isLoading ? 'Mengirim...' : (customText ?? 'Simpan'),
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: Icons.save,
    );
  }
}