import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

// Supported provider types
enum SocialLoginProvider { google, facebook, apple, phone }

class SocialLoginButton extends StatelessWidget {
  final SocialLoginProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  // ── Provider display config ─────────────────────────────────────────────────
  _ProviderConfig get _config {
    switch (provider) {
      case SocialLoginProvider.google:
        return _ProviderConfig(
          label: 'Continue with Google',
          icon: _GoogleIcon(),
          backgroundColor: Colors.white,
          textColor: AppColors.textPrimary,
          borderColor: Colors.grey.shade300,
        );
      case SocialLoginProvider.facebook:
        return _ProviderConfig(
          label: 'Continue with Facebook',
          icon: const Icon(Icons.facebook, color: Colors.white, size: 22),
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
          borderColor: const Color(0xFF1877F2),
        );
      case SocialLoginProvider.apple:
        return _ProviderConfig(
          label: 'Continue with Apple',
          icon: const Icon(Icons.apple, color: Colors.white, size: 24),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          borderColor: Colors.black,
        );
      case SocialLoginProvider.phone:
        return _ProviderConfig(
          label: 'Continue with Phone',
          icon: const Icon(Icons.phone_outlined,
              color: AppColors.primaryGreen, size: 22),
          backgroundColor: Colors.white,
          textColor: AppColors.primaryGreen,
          borderColor: AppColors.primaryGreen,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cfg.backgroundColor,
          disabledBackgroundColor: cfg.backgroundColor.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cfg.borderColor, width: 1.5),
          ),
          shadowColor: Colors.black.withOpacity(0.08),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cfg.textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: cfg.icon,
                  ),
                  const SizedBox(width: 12),
                  // Label
                  Text(
                    cfg.label,
                    style: AppTextStyles.bodyText.copyWith(
                      color: cfg.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Configuration data class ────────────────────────────────────────────────
class _ProviderConfig {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  _ProviderConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

// ── Custom Google "G" icon painted manually (no image asset needed) ──────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _GooglePainter(),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Blue arc (top)
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Red arc (bottom-left)
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    // Yellow arc (bottom)
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;

    // Green arc (top-right)
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Draw 4 colored quarter arcs
    canvas.drawArc(rect, -1.57, 1.57, true, paintBlue);
    canvas.drawArc(rect, 0.0, 1.57, true, paintGreen);
    canvas.drawArc(rect, 1.57, 1.57, true, paintYellow);
    canvas.drawArc(rect, 3.14, 1.57, true, paintRed);

    // White center circle to create the "G" cutout ring effect
    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, paintWhite);

    // White horizontal bar for "G" opening
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.18, r, r * 0.36),
      paintWhite,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// HOW TO USE in login_page.dart:
//
// Column(
//   children: [
//     SocialLoginButton(
//       provider: SocialLoginProvider.google,
//       onPressed: () { /* trigger Google sign in */ },
//     ),
//     const SizedBox(height: 12),
//     SocialLoginButton(
//       provider: SocialLoginProvider.phone,
//       onPressed: () => Navigator.pushNamed(context, RouteNames.otp,
//           arguments: {'phoneNumber': ''}),
//     ),
//   ],
// )
// ─────────────────────────────────────────────────────────────────────────────
