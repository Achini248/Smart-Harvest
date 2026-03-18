import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<AuthStateChanged>(_onAuthStateChanged);

    _authSubscription =
        _firebaseAuth.authStateChanges().listen((user) {
          add(AuthStateChanged(user));
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
      // authStateChanges stream will update state
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
      // authStateChanges stream will update state
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Registration error"));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> _onGoogleLogin(
    GoogleLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(const AuthError(message: "Google sign in cancelled"));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // Firebase auth stream will emit Authenticated state
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Google login error"));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _googleSignIn.signOut(); // logout from google
    await _firebaseAuth.signOut();
  }

  Future<void> _onAuthStateChanged(
      AuthStateChanged event,
      Emitter<AuthState> emit,
      ) async {
    final user = event.user;

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
  }

  // ---------------- CLOSE ----------------
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}