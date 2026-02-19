import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String phoneNo);
  Future<UserModel> signInWithGoogle(); // NEW
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn; // NEW

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn, // NEW
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed');
      }

      return UserModel(
        id: credential.user!.uid,
        email: credential.user!.email!,
        name: credential.user!.displayName,
        phoneNo: credential.user!.phoneNumber,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String phoneNo) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Registration failed');
      }

      return UserModel(
        id: credential.user!.uid,
        email: email,
        phoneNo: phoneNo,
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // NEW: Google Sign-In Implementation
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google Sign-In failed');
      }

      return UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName,
        phoneNo: userCredential.user!.phoneNumber,
        profilePhotoUrl: userCredential.user!.photoURL,
      );
    } catch (e) {
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(), // Sign out from Google too
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      email: user.email!,
      name: user.displayName,
      phoneNo: user.phoneNumber,
    );
  }
}
