import 'package:appventas/models/quotation/terms_conditions.dart';
import 'package:appventas/services/http_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/services/terms_conditions_service.dart';
import 'terms_conditions_event.dart';
import 'terms_conditions_state.dart';

class TermsConditionsBloc extends Bloc<TermsConditionsEvent, TermsConditionsState> {
  PaymentMethod? _selectedPaymentMethod;
  DeliveryTime? _selectedDeliveryTime;
  OfferValidity? _selectedOfferValidity;
  
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  DeliveryTime? get selectedDeliveryTime => _selectedDeliveryTime;
  OfferValidity? get selectedOfferValidity => _selectedOfferValidity;

  TermsConditionsBloc() : super(TermsConditionsInitial()) {
    on<TermsConditionsLoadRequested>(_onTermsConditionsLoadRequested);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<DeliveryTimeSelected>(_onDeliveryTimeSelected);
    on<OfferValiditySelected>(_onOfferValiditySelected);
    on<TermsConditionsCleared>(_onTermsConditionsCleared);
  }

  Future<void> _onTermsConditionsLoadRequested(
    TermsConditionsLoadRequested event,
    Emitter<TermsConditionsState> emit,
  ) async {
    try {
      emit(TermsConditionsLoading());
      
      final termsConditions = await TermsConditionsService.getAllTermsConditions();

      emit(TermsConditionsLoaded(
        termsConditions: termsConditions,
        selectedPaymentMethod: _selectedPaymentMethod,
        selectedDeliveryTime: _selectedDeliveryTime,
        selectedOfferValidity: _selectedOfferValidity,
      ));
    } on UnauthorizedException {
      // HttpClient ya manejó la redirección
      print('🔓 Sesión expirada detectada en TermsConditionsBloc');
    } catch (e) {
      emit(TermsConditionsError('Error al cargar términos y condiciones: ${e.toString()}'));
    }
  }

  void _onPaymentMethodSelected(
    PaymentMethodSelected event,
    Emitter<TermsConditionsState> emit,
  ) {
    _selectedPaymentMethod = event.paymentMethod;
    
    if (state is TermsConditionsLoaded) {
      final currentState = state as TermsConditionsLoaded;
      emit(currentState.copyWith(
        selectedPaymentMethod: event.paymentMethod,
        updatePaymentMethod: true, // Solo actualizar este campo
      ));
    }
  }

  void _onDeliveryTimeSelected(
    DeliveryTimeSelected event,
    Emitter<TermsConditionsState> emit,
  ) {
    _selectedDeliveryTime = event.deliveryTime;
    
    if (state is TermsConditionsLoaded) {
      final currentState = state as TermsConditionsLoaded;
      emit(currentState.copyWith(
        selectedDeliveryTime: event.deliveryTime,
        updateDeliveryTime: true, // Solo actualizar este campo
      ));
    }
  }

  void _onOfferValiditySelected(
    OfferValiditySelected event,
    Emitter<TermsConditionsState> emit,
  ) {
    _selectedOfferValidity = event.offerValidity;
    
    if (state is TermsConditionsLoaded) {
      final currentState = state as TermsConditionsLoaded;
      emit(currentState.copyWith(
        selectedOfferValidity: event.offerValidity,
        updateOfferValidity: true, // Solo actualizar este campo
      ));
    }
  }

  void _onTermsConditionsCleared(
    TermsConditionsCleared event,
    Emitter<TermsConditionsState> emit,
  ) {
    _selectedPaymentMethod = null;
    _selectedDeliveryTime = null;
    _selectedOfferValidity = null;
    
    emit(TermsConditionsInitial());
  }
}