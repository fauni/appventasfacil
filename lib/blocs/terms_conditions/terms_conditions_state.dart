import 'package:appventas/models/quotation/terms_conditions.dart';
import 'package:equatable/equatable.dart';

abstract class TermsConditionsState extends Equatable {
  const TermsConditionsState();

  @override
  List<Object?> get props => [];
}

class TermsConditionsInitial extends TermsConditionsState {}

class TermsConditionsLoading extends TermsConditionsState {}

class TermsConditionsLoaded extends TermsConditionsState {
  final TermsConditions termsConditions;
  final PaymentMethod? selectedPaymentMethod;
  final DeliveryTime? selectedDeliveryTime;
  final OfferValidity? selectedOfferValidity;

  const TermsConditionsLoaded({
    required this.termsConditions,
    this.selectedPaymentMethod,
    this.selectedDeliveryTime,
    this.selectedOfferValidity,
  });

  // FIX: Usar un método copyWith que preserve los valores existentes
  TermsConditionsLoaded copyWith({
    TermsConditions? termsConditions,
    PaymentMethod? selectedPaymentMethod,
    DeliveryTime? selectedDeliveryTime,
    OfferValidity? selectedOfferValidity,
    // Añadir flags para distinguir entre "no cambiar" y "cambiar a null"
    bool updatePaymentMethod = false,
    bool updateDeliveryTime = false,
    bool updateOfferValidity = false,
  }) {
    return TermsConditionsLoaded(
      termsConditions: termsConditions ?? this.termsConditions,
      selectedPaymentMethod: updatePaymentMethod 
          ? selectedPaymentMethod 
          : this.selectedPaymentMethod,
      selectedDeliveryTime: updateDeliveryTime 
          ? selectedDeliveryTime 
          : this.selectedDeliveryTime,
      selectedOfferValidity: updateOfferValidity 
          ? selectedOfferValidity 
          : this.selectedOfferValidity,
    );
  }

  @override
  List<Object?> get props => [
    termsConditions,
    selectedPaymentMethod,
    selectedDeliveryTime,
    selectedOfferValidity,
  ];
}

class TermsConditionsError extends TermsConditionsState {
  final String message;

  const TermsConditionsError(this.message);

  @override
  List<Object> get props => [message];
}