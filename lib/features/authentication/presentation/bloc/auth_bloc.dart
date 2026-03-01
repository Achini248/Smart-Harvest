import 'package:flutter_bloc/flutter_bloc.dart';

// UserEntity එක තියෙන තැන import එක නිවැරදිද බලන්න
import '../../domain/entities/user.dart'; 
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  // const අයින් කළා
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // const අයින් කළා
    try {
      // Repository එකේ login function එකේ arguments පිළිවෙළ බලන්න
      final result = await authRepository.login(event.email, event.password);
      
      // Dartz (Either) පාවිච්චි කරනවා නම් fold කරන්න ඕනේ
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(Authenticated(user: user)),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // const අයින් කළා
    try {
      // Repository එකේ register function එකට values යවනවා
      final result = await authRepository.register(
        event.email,
        event.password,
        event.phoneNo, // event එකේ තියෙන parameters පාවිච්චි කරන්න
      );

      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(Authenticated(user: user)),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // const අයින් කළා
    try {
      await authRepository.logout();
      emit(Unauthenticated()); // const අයින් කළා
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated()); // const අයින් කළා
      }
    } catch (_) {
      emit(Unauthenticated()); // const අයින් කළා
    }
  }
}