import 'package:appventas/blocs/payment_group/payment_group_event.dart';
import 'package:appventas/blocs/payment_group/payment_group_state.dart';
import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/payment_group_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentGroupBloc extends Bloc<PaymentGroupEvent, PaymentGroupState>{
  PaymentGroup? _selectedPaymentGroup;

  PaymentGroup? get selectedPaymentGroup => _selectedPaymentGroup;

  PaymentGroupBloc() : super(PaymentGroupInitial()){
    on<PaymentGroupSearchRequested>(_onPaymentGroupSearchRequested);
    on<PaymentGroupLoadMoreRequested>(_onPaymentGroupLoadMoreRequested);
    on<PaymentGroupSelected>(_onPaymentGroupSelected);
    on<PaymentGroupByGroupNumRequested>(_onPaymentGroupByGroupNumRequested);
    on<PaymentGroupSearchCleared>(_onPaymentGroupSearchCleared);
    on<PaymentGroupSelectionCleared>(_onPaymentSelectionCleared);
  }

  Future<void> _onPaymentGroupSearchRequested(PaymentGroupSearchRequested event, Emitter<PaymentGroupState> emit) async {
    try {
      emit(PaymentGroupLoading());
      
      final response = await PaymentGroupService.searchPaymentGroups(
        searchTerm: event.searchTerm,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );
      emit(PaymentGroupSearchLoaded(response: response, searchTerm: event.searchTerm));
    } on UnauthorizedException catch(e){
      print('Sesión expirada detectada en PaymentGroupBloc');
    } catch (e) {
      emit(PaymentGroupInitial()); // Handle error appropriately
    }
  }

  Future<void> _onPaymentGroupLoadMoreRequested(
    PaymentGroupLoadMoreRequested event,
    Emitter<PaymentGroupState> emit,
  ) async {
    try {
      if (state is PaymentGroupSearchLoaded) {
        final currentState = state as PaymentGroupSearchLoaded;
        
        emit(PaymentGroupLoadingMore(
          currentPaymentGroups: currentState.response.paymentGroups,
          currentPage: currentState.response.pageNumber,
          searchTerm: event.searchTerm,
        ));

        final response = await PaymentGroupService.searchPaymentGroups(
          searchTerm: event.searchTerm,
          pageNumber: event.currentPage + 1,
          pageSize: event.pageSize,
        );

        final allPaymentGroups = List<PaymentGroup>.from(currentState.response.paymentGroups)
          ..addAll(response.paymentGroups);

        emit(PaymentGroupSearchLoadedMore(
          response: response,
          searchTerm: event.searchTerm,
          allPaymentGroups: allPaymentGroups,
        ));
      }
    } catch (e) {
      emit(PaymentGroupInitial()); // Handle error appropriately
    }
  }

  Future<void> _onPaymentGroupByGroupNumRequested(
    PaymentGroupByGroupNumRequested event,
    Emitter<PaymentGroupState> emit,
  ) async {
    try {
      emit(PaymentGroupLoading());

      final paymentGroup = await PaymentGroupService.getPaymentGroupByGroupNum(event.groupNum);
      _selectedPaymentGroup = paymentGroup;

      emit(PaymentGroupDetailLoaded(paymentGroup));
    } on UnauthorizedException catch (e) {
      print('Sesión expirada detectada en PaymentGroupBloc');
    } catch (e) {
      emit(PaymentGroupInitial()); // Handle error appropriately
    }
  }

  Future<void> _onPaymentGroupSelected(
    PaymentGroupSelected event,
    Emitter<PaymentGroupState> emit,
  ) async {
    _selectedPaymentGroup = event.paymentGroup;
    emit(PaymentGroupSelectedState(event.paymentGroup));
  }

  void _onPaymentGroupSearchCleared(
    PaymentGroupSearchCleared event,
    Emitter<PaymentGroupState> emit,
  ) {
    _selectedPaymentGroup = null;
    emit(PaymentGroupInitial());
  }

  void _onPaymentSelectionCleared(
    PaymentGroupSelectionCleared event,
    Emitter<PaymentGroupState> emit,
  ) {
    _selectedPaymentGroup = null;
    emit(PaymentGroupInitial());
  }

}