//Update onboarding_state.dart
import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  final int pageIndex;

  const OnboardingState({required this.pageIndex});

  @override
  List<Object> get props => [pageIndex];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial() : super(pageIndex: 0);
}

class OnboardingPageUpdate extends OnboardingState {
  const OnboardingPageUpdate(int index) : super(pageIndex: index);
}

class OnboardingComplete extends OnboardingState {
  const OnboardingComplete() : super(pageIndex: 2);
}
