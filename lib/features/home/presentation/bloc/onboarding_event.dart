import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class OnboardingNextPressed extends OnboardingEvent {
  // Current index is needed to decide whether to increment or finish
  final int currentIndex; 

  const OnboardingNextPressed(this.currentIndex);
  
  @override
  List<Object> get props => [currentIndex];
}

class OnboardingSkipPressed extends OnboardingEvent {}

class OnboardingBackPressed extends OnboardingEvent {
  final int currentIndex;
  const OnboardingBackPressed(this.currentIndex);
  @override
  List<Object> get props => [currentIndex];
}
