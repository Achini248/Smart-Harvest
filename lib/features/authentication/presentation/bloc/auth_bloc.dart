import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  Timer? _resendTimer;
  int _secondsLeft = 60;
  String? _cachedVerificationId;
  String? _cachedPhone;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthResendOtpEvent>(_onResendOtp);
    on<AuthTimerTickEvent>(_onTimerTick);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
  }

  // ── Check auth status ───────────────────────────────────────────────────────
  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Replace with actual repository check when Firebase is connected
      await Future.delayed(const Duration(milliseconds: 300));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────
  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
      emit(AuthUnauthenticated());
    }
  }

  // ── Register ────────────────────────────────────────────────────────────────
  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(
        event.email,
        event.password,
        event.phone,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
      emit(AuthUnauthenticated());
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────────
  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    _resendTimer?.cancel();
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }

  // ── Send OTP ────────────────────────────────────────────────────────────────
  Future<void> _onSendOtp(
    AuthSendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final verificationId = await sendOtpUseCase(event.phoneNumber);
      _cachedVerificationId = verificationId;
      _cachedPhone = event.phoneNumber;
      emit(AuthOtpSent(
        verificationId: verificationId,
        phoneNumber: event.phoneNumber,
      ));
      _startResendTimer(verificationId, event.phoneNumber);
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
      emit(AuthUnauthenticated());
    }
  }

  // ── Verify OTP ──────────────────────────────────────────────────────────────
  Future<void> _onVerifyOtp(
    AuthVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      _resendTimer?.cancel();
      final user = await verifyOtpUseCase(
        event.verificationId,
        event.otpCode,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
      if (_cachedVerificationId != null && _cachedPhone != null) {
        emit(AuthOtpSent(
          verificationId: _cachedVerificationId!,
          phoneNumber: _cachedPhone!,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  // ── Resend OTP ──────────────────────────────────────────────────────────────
  Future<void> _onResendOtp(
    AuthResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    _resendTimer?.cancel();
    add(AuthSendOtpEvent(event.phoneNumber));
  }

  // ── Timer tick ──────────────────────────────────────────────────────────────
  void _onTimerTick(
    AuthTimerTickEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthOtpTimerTick(
      verificationId: event.verificationId,
      phoneNumber: event.phoneNumber,
      secondsLeft: event.secondsLeft,
    ));
  }

  // ── Update profile ──────────────────────────────────────────────────────────
  Future<void> _onUpdateProfile(
    AuthUpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      const updatedUser = User(
        id: 'current_user',
        email: 'user@smartharvest.lk',
      );
      emit(AuthProfileUpdated(updatedUser));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  // ── Start countdown timer ───────────────────────────────────────────────────
  void _startResendTimer(String verificationId, String phone) {
    _secondsLeft = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsLeft--;
      if (!isClosed) {
        add(AuthTimerTickEvent(verificationId, phone, _secondsLeft));
      }
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  // ── Friendly Firebase error messages ────────────────────────────────────────
  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid-phone-number')) {
      return 'Invalid phone number. Use format +94XXXXXXXXX';
    }
    if (msg.contains('invalid-verification-code')) {
      return 'Incorrect OTP. Please try again.';
    }
    if (msg.contains('session-expired')) {
      return 'OTP expired. Please request a new one.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please wait and try again.';
    }
    if (msg.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (msg.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'This email is already registered. Please login.';
    }
    if (msg.contains('weak-password')) {
      return 'Password too weak. Use at least 6 characters.';
    }
    if (msg.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }
    return e.toString();
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
