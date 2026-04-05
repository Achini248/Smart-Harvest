// lib/features/authentication/presentation/bloc/auth_bloc.dart
// Smart Harvest — Authentication BLoC with OTP registration flow.
// All HTTP calls go through ApiClient.instance so the base URL is resolved
// dynamically per platform (Android emulator / iOS / web / real device).

import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final StreamSubscription<User?> _authSubscription;

  AuthBloc() : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpAndRegisterEvent>(_onVerifyOtpAndRegister);
    on<LogoutEvent>(_onLogout);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<ForgotPasswordEvent>(_onForgotPassword);

    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        emit(Authenticated(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        ));
        _syncProfile(user);
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ── Register (kept for Google Sign-In path) ────────────────────────────────
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (event.displayName != null && event.displayName!.isNotEmpty) {
        await cred.user?.updateDisplayName(event.displayName);
        await cred.user?.reload();
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ── OTP Step 1: Send ───────────────────────────────────────────────────────
  // Uses ApiClient.instance.post() — base URL is resolved dynamically:
  //   Web            → http://localhost:5000
  //   Android emu    → http://10.0.2.2:5000
  //   iOS sim        → http://localhost:5000
  //   Real device    → --dart-define=API_BASE_URL=http://YOUR_IP:5000
  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      // ApiClient.instance.post() handles base URL + Content-Type automatically.
      // No Firebase token is attached because the user has no account yet —
      // ApiClient gracefully omits the Authorization header when currentUser is null.
      await ApiClient.instance.post(
        ApiConstants.otpSend,
        {'email': event.email.trim().toLowerCase()},
      );
      emit(OtpSent(email: event.email.trim().toLowerCase()));
    } catch (e) {
      emit(AuthError(message: _extractMessage(e)));
    }
  }

  // ── OTP Step 2: Verify then Register ──────────────────────────────────────
  Future<void> _onVerifyOtpAndRegister(
      VerifyOtpAndRegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      // 1. Verify OTP — backend deletes the record on success (single-use).
      await ApiClient.instance.post(
        ApiConstants.otpVerify,
        {
          'email': event.email.trim().toLowerCase(),
          'otp':   event.otp.trim(),
        },
      );

      // 2. OTP verified — now create the Firebase account.
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      if (event.displayName != null && event.displayName!.isNotEmpty) {
        await cred.user?.updateDisplayName(event.displayName);
        await cred.user?.reload();
      }
      // The authStateChanges listener will emit Authenticated automatically.
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: _extractMessage(e)));
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────────────
  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(const Unauthenticated());
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Google sign-in failed. Please try again.'));
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(const PasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Failed to send reset email. Please try again.'));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ── Sync profile to backend ────────────────────────────────────────────────
  Future<void> _syncProfile(User user) async {
    try {
      await ApiClient.instance.post(ApiConstants.authProfile, {
        'email': user.email ?? '',
        'name':  user.displayName ?? (user.email?.split('@').first ?? 'User'),
      });
    } catch (_) {}
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Pulls a readable message out of any exception type, including the custom
  /// ServerException / NetworkException thrown by ApiClient.
  String _extractMessage(Object e) {
    // Our custom exceptions expose a .message field — extract it via toString
    final raw = e.toString();
    // e.g. "ServerException: Incorrect OTP. Please try again."
    final colon = raw.indexOf(':');
    if (colon != -1 && colon < raw.length - 1) {
      return raw.substring(colon + 1).trim();
    }
    return raw;
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      case 'popup-blocked':
        return 'Pop-up was blocked by the browser. Please allow pop-ups.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
