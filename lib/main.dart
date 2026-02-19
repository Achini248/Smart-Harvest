import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'app.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(
            firebaseAuth: firebase_auth.FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
          ),
        ),
      ),
      child: const SmartHarvestApp(),
    );
  }
}
