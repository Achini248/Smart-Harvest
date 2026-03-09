import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final int totalPages = 3;

  OnboardingBloc() : super(const OnboardingInitial()) {
    on<OnboardingPageChanged>((event, emit) {
      emit(OnboardingPageUpdate(event.pageIndex));
    });

    on<OnboardingNextPressed>((event, emit) {
      if (event.currentIndex < totalPages - 1) {
        emit(OnboardingPageUpdate(event.currentIndex + 1));
      } else {
        emit(const OnboardingComplete());
      }
    });

    on<OnboardingSkipPressed>((event, emit) {
      emit(const OnboardingComplete());
    });
    
    on<OnboardingBackPressed>((event, emit) {
       if (event.currentIndex > 0) {
        emit(OnboardingPageUpdate(event.currentIndex - 1));
      }
    });
  }
}
