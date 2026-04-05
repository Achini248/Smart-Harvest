// lib/features/authentication/presentation/pages/otp_verification_page.dart
// Smart Harvest — OTP Verification Page
//
// Receives registration details via route arguments:
//   { 'email': String, 'password': String, 'name': String, 'phone': String }
//
// Flow:
//   1. Displays the email the OTP was sent to.
//   2. User enters the 6-digit code.
//   3. On "Verify" → VerifyOtpAndRegisterEvent → backend verifies OTP →
//      Firebase createUserWithEmailAndPassword → Authenticated state → home.
//   4. "Resend" button (enabled after 60-second countdown).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength    = 6;
  static const int _resendDelay  = 60; // seconds

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _nodes =
      List.generate(_otpLength, (_) => FocusNode());

  late Map<String, dynamic> _args;
  bool _argsLoaded = false;

  // Resend countdown
  int _secondsLeft = _resendDelay;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _args = (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?) ??
          {};
      _argsLoaded = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  // ── Countdown ──────────────────────────────────────────────────────────────

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendDelay);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // ── Input Handling ─────────────────────────────────────────────────────────

  void _onChanged(int index, String value) {
    // Allow paste of full code
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length < _otpLength) ? digits.length : _otpLength - 1;
      FocusScope.of(context).requestFocus(_nodes[next]);
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_nodes[index + 1]);
    }
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    // On backspace in an empty field → move focus back
    if (event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_nodes[index - 1]);
      _controllers[index - 1].clear();
    }
  }

  String get _enteredOtp =>
      _controllers.map((c) => c.text).join();

  // ── Actions ────────────────────────────────────────────────────────────────

  void _verify() {
    final otp = _enteredOtp;
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          VerifyOtpAndRegisterEvent(
            email:       _args['email'] as String? ?? '',
            otp:         otp,
            password:    _args['password'] as String? ?? '',
            displayName: _args['name'] as String?,
          ),
        );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    // Clear fields
    for (final c in _controllers) c.clear();
    FocusScope.of(context).requestFocus(_nodes[0]);

    context.read<AuthBloc>().add(
          SendOtpEvent(email: _args['email'] as String? ?? ''),
        );
    _startCountdown();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local  = parts[0];
    final domain = parts[1];
    if (local.length <= 3) return '***@$domain';
    return '${local.substring(0, 3)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final email = _args['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFDFDFD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Email Verification',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Registration complete — go to home, clear the back stack.
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.home,
              (_) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is OtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('A new code has been sent to your email.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ── Icon ──────────────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────────
                const Text(
                  'Check your inbox',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We sent a 6-digit verification code to',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  _maskedEmail(email),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),

                // ── OTP Boxes ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_otpLength, (i) {
                    return SizedBox(
                      width: 46,
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (e) => _onKeyDown(i, e),
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _nodes[i],
                          onChanged: (v) => _onChanged(i, v),
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 36),

                // ── Verify Button ─────────────────────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          disabledBackgroundColor:
                              AppColors.primaryGreen.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify & Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Resend ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    _secondsLeft > 0
                        ? Text(
                            'Resend in ${_secondsLeft}s',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : GestureDetector(
                            onTap: _resend,
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Hint ──────────────────────────────────────────────────
                Text(
                  'The code expires in 10 minutes.\nCheck your spam folder if you don\'t see it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
