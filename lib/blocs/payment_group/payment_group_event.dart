import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentGroupEvent extends Equatable {
  const PaymentGroupEvent();

  @override
  List<Object> get props => [];
}

class PaymentGroupSearchRequested extends PaymentGroupEvent {
  final String searchTerm;
  final int pageNumber;
  final int pageSize;

  const PaymentGroupSearchRequested({
    this.searchTerm = '',
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  @override
  List<Object> get props => [searchTerm, pageNumber, pageSize];
}

class PaymentGroupLoadMoreRequested extends PaymentGroupEvent {
  final String searchTerm;
  final int currentPage;
  final int pageSize;

  const PaymentGroupLoadMoreRequested({
    required this.searchTerm,
    required this.currentPage,
    required this.pageSize,
  });

  @override
  List<Object> get props => [searchTerm, currentPage, pageSize];
}

class PaymentGroupSelected extends PaymentGroupEvent {
  final PaymentGroup paymentGroup;

  const PaymentGroupSelected(this.paymentGroup);

  @override
  List<Object> get props => [paymentGroup];
}

class PaymentGroupByGroupNumRequested extends PaymentGroupEvent {
  final int groupNum;

  const PaymentGroupByGroupNumRequested(this.groupNum);

  @override
  List<Object> get props => [groupNum];
}

// class PaymentGroupAutocompleteRequested extends PaymentGroupEvent {
//   final String term;

//   const PaymentGroupAutocompleteRequested(this.term);

//   @override
//   List<Object> get props => [term];
// }

class PaymentGroupSearchCleared extends PaymentGroupEvent {}
class PaymentGroupSelectionCleared extends PaymentGroupEvent {}
