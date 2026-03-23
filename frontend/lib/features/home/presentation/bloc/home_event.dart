// lib/features/home/presentation/bloc/home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}
