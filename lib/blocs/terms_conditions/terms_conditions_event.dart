import 'package:appventas/models/quotation/terms_conditions.dart';
import 'package:equatable/equatable.dart';

abstract class TermsConditionsEvent extends Equatable {
  const TermsConditionsEvent();

  @override
  List<Object> get props => [];
}

class TermsConditionsLoadRequested extends TermsConditionsEvent {}

class PaymentMethodSelected extends TermsConditionsEvent {
  final PaymentMethod paymentMethod;

  const PaymentMethodSelected(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class DeliveryTimeSelected extends TermsConditionsEvent {
  final DeliveryTime deliveryTime;

  const DeliveryTimeSelected(this.deliveryTime);

  @override
  List<Object> get props => [deliveryTime];
}

class OfferValiditySelected extends TermsConditionsEvent {
  final OfferValidity offerValidity;

  const OfferValiditySelected(this.offerValidity);

  @override
  List<Object> get props => [offerValidity];
}

class TermsConditionsCleared extends TermsConditionsEvent {}
