import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:equatable/equatable.dart';


abstract class PaymentGroupState extends Equatable {
  const PaymentGroupState();

  @override
  List<Object?> get props => [];
}


class PaymentGroupInitial extends PaymentGroupState {}

class PaymentGroupLoading extends PaymentGroupState {}

class PaymentGroupLoadingMore extends PaymentGroupState {
  final List<PaymentGroup> currentPaymentGroups;
  final int currentPage;
  final String searchTerm;
  
  const PaymentGroupLoadingMore({
    required this.currentPaymentGroups,
    required this.currentPage,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [currentPaymentGroups, currentPage, searchTerm];
} 

class PaymentGroupSearchLoaded extends PaymentGroupState {
  final PaymentGroupSearchResponse response;
  final String searchTerm;

  const PaymentGroupSearchLoaded({
    required this.response,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [response, searchTerm];
}

class PaymentGroupSearchLoadedMore extends PaymentGroupState {
  final PaymentGroupSearchResponse response;
  final String searchTerm;
  final List<PaymentGroup> allPaymentGroups;

  const PaymentGroupSearchLoadedMore({
    required this.response,
    required this.searchTerm,
    required this.allPaymentGroups,
  });

  @override
  List<Object> get props => [response, searchTerm, allPaymentGroups];
}

class PaymentGroupDetailLoaded extends PaymentGroupState {
  final PaymentGroup paymentGroup;

  const PaymentGroupDetailLoaded(this.paymentGroup);

  @override
  List<Object> get props => [paymentGroup];
}

class PaymentGroupSelectedState extends PaymentGroupState {
  final PaymentGroup paymentGroup;

  const PaymentGroupSelectedState(this.paymentGroup);

  @override
  List<Object> get props => [paymentGroup];
}

class PaymentGroupError extends PaymentGroupState {
  final String message;

  const PaymentGroupError(this.message);

  @override
  List<Object> get props => [message];
}