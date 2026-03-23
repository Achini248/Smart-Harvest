import 'dart:async';
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

  // ── Register ───────────────────────────────────────────────────────────────
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
      await cred.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────────────
  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
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
      emit(AuthError(
          message: 'Failed to send reset email. Please try again.'));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ── Sync profile ───────────────────────────────────────────────────────────
  Future<void> _syncProfile(User user) async {
    try {
      await ApiClient.instance.post(ApiConstants.authProfile, {
        'email': user.email ?? '',
        'name': user.displayName ??
            (user.email?.split('@').first ?? 'User'),
      });
    } catch (_) {}
  }

  // ── Friendly error messages ────────────────────────────────────────────────
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
