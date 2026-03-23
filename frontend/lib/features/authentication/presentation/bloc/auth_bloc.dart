// lib/features/authentication/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _authSubscription;

  AuthBloc() : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);

    // Firebase auth state stream drives all state changes
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        emit(Authenticated(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        ));
        // Sync profile to Flask backend (non-blocking)
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
      // Stream listener emits Authenticated and calls _syncProfile
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
      // Update display name if provided
      if (event.displayName != null && event.displayName!.isNotEmpty) {
        await cred.user?.updateDisplayName(event.displayName);
        await cred.user?.reload();
      }
      // Stream listener handles the rest
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _friendlyError(e.code)));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
  }

  // ── Sync profile to Flask backend ──────────────────────────────────────────
  /// Called automatically after every login / registration.
  /// Creates or updates the Firestore user document via Flask.
  Future<void> _syncProfile(User user) async {
    try {
      await ApiClient.instance.post(ApiConstants.authProfile, {
        'email': user.email ?? '',
        'name':  user.displayName ?? (user.email?.split('@').first ?? 'User'),
      });
    } catch (_) {
      // Profile sync failure should not block the user
    }
  }

  // ── Human-readable Firebase errors ────────────────────────────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':      return 'No account found with this email.';
      case 'wrong-password':      return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists for this email.';
      case 'weak-password':       return 'Password must be at least 6 characters.';
      case 'invalid-email':       return 'Please enter a valid email address.';
      case 'user-disabled':       return 'This account has been disabled.';
      case 'too-many-requests':   return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'No internet connection.';
      default:                    return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
