import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.verificationId,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  String? _verificationId;
  bool _canResend = false;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;

    // Auto-send OTP on page load if no verificationId provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verificationId == null) {
        context.read<AuthBloc>().add(
              AuthSendOtpEvent(widget.phoneNumber),
            );
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  void _onVerify() {
    final otp = _otpCode;
    if (otp.length < 6) {
      _showSnack('Please enter all 6 digits', isError: true);
      return;
    }
    if (_verificationId == null) {
      _showSnack('Please wait for OTP to be sent', isError: true);
      return;
    }
    context.read<AuthBloc>().add(
          AuthVerifyOtpEvent(_verificationId!, otp),
        );
  }

  void _onResend() {
    if (!_canResend) return;
    // Clear all boxes
    for (final c in _controllers) c.clear();
    setState(() {
      _canResend = false;
      _secondsLeft = 60;
    });
    _focusNodes[0].requestFocus();
    context.read<AuthBloc>().add(
          AuthResendOtpEvent(widget.phoneNumber),
        );
  }

  void _onBoxChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit — try verify automatically
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) _onVerify();
      }
    }
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    final prefix = phone.substring(0, phone.length - 6);
    final suffix = phone.substring(phone.length - 3);
    return '${prefix}***$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.home,
              (_) => false,
            );
          } else if (state is AuthOtpSent) {
            _verificationId = state.verificationId;
            setState(() {
              _secondsLeft = 60;
              _canResend = false;
            });
            _showSnack('OTP sent successfully!');
          } else if (state is AuthOtpTimerTick) {
            _verificationId = state.verificationId;
            setState(() {
              _secondsLeft = state.secondsLeft;
              _canResend = state.secondsLeft <= 0;
            });
          } else if (state is AuthError) {
            for (final c in _controllers) c.clear();
            _focusNodes[0].requestFocus();
            _showSnack(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isSendingOtp = isLoading && _verificationId == null;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Back button ────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Lock icon ──────────────────────────────────────
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'OTP Verification',
                    style: AppTextStyles.heading2.copyWith(fontSize: 26),
                  ),

                  const SizedBox(height: 12),

                  if (isSendingOtp) ...[
                    const SizedBox(height: 8),
                    const CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                    const SizedBox(height: 12),
                    Text(
                      'Sending OTP to ${_maskPhone(widget.phoneNumber)}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ] else ...[
                    Text(
                      'Enter the 6-digit code sent to',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _maskPhone(widget.phoneNumber),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // ── 6 OTP input boxes ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 46,
                        height: 56,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 5),
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onKeyEvent(i, event),
                          child: TextFormField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: _controllers[i].text.isNotEmpty
                                  ? AppColors.primaryGreen.withOpacity(0.08)
                                  : Colors.grey.shade50,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryGreen,
                                    width: 2.5),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.5),
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {}); // Refresh fill color
                              _onBoxChanged(i, v);
                            },
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // ── Countdown / Resend ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: AppTextStyles.bodyText
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: _canResend && !isLoading
                            ? _onResend
                            : null,
                        child: Text(
                          _canResend
                              ? 'Resend OTP'
                              : 'Resend in ${_secondsLeft}s',
                          style: AppTextStyles.bodyText.copyWith(
                            color: _canResend
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Verify button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor:
                            AppColors.primaryGreen.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _onVerify,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Verify OTP',
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Change number ──────────────────────────────────
                  TextButton(
                    onPressed:
                        isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Change phone number',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
