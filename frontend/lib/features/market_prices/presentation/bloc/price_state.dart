import 'package:equatable/equatable.dart';
import '../../domain/entities/price.dart';

class PriceState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<PriceEntity> allPrices;      // මේක එකතු කළා
  final List<PriceEntity> filteredPrices; // UI එකේ පාවිච්චි වෙන්නේ මේකයි
  final Map<DateTime, double> trends;
  final String? selectedProduct;

  const PriceState({
    required this.isLoading,
    required this.allPrices,
    required this.filteredPrices,
    required this.trends,
    this.errorMessage,
    this.selectedProduct,
  });

  factory PriceState.initial() {
    return const PriceState(
      isLoading: false,
      allPrices: [],
      filteredPrices: [],
      trends: {},
      errorMessage: null,
      selectedProduct: null,
    );
  }

  PriceState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PriceEntity>? allPrices,
    List<PriceEntity>? filteredPrices,
    Map<DateTime, double>? trends,
    String? selectedProduct,
    bool clearError = false, // Error එක අයින් කරන්න ඕන වුණොත් පාවිච්චි කරන්න
  }) {
    return PriceState(
      isLoading: isLoading ?? this.isLoading,
      allPrices: allPrices ?? this.allPrices,
      filteredPrices: filteredPrices ?? this.filteredPrices,
      trends: trends ?? this.trends,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        allPrices,
        filteredPrices,
        trends,
        selectedProduct,
      ];
}