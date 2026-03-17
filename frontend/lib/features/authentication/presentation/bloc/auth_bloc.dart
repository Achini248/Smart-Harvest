import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _authSubscription;

  AuthBloc() : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);

    // 🔥 Listen to Firebase auth state directly
    _authSubscription =
        _firebaseAuth.authStateChanges().listen((user) {
          if (user != null) {
            emit(
              Authenticated(
                uid: user.uid,
                email: user.email,
                displayName: user.displayName,
              ),
            );
          } else {
            emit(const Unauthenticated());
          }
        });
  }

  // ---------------- LOGIN ----------------
  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      // No manual emit — stream handles it
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Login error"));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ---------------- REGISTER ----------------
  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      // Stream handles state
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Registration error"));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    await _firebaseAuth.signOut();
    // Stream handles state
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}