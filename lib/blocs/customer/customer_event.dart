// lib/blocs/customer/customer_event.dart
import 'package:equatable/equatable.dart';
import 'package:appventas/models/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class CustomerSearchRequested extends CustomerEvent {
  final String searchTerm;
  final int pageNumber;
  final int pageSize;

  const CustomerSearchRequested({
    this.searchTerm = '',
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  @override
  List<Object> get props => [searchTerm, pageNumber, pageSize];
}

class CustomerLoadMoreRequested extends CustomerEvent {
  final String searchTerm;
  final int currentPage;
  final int pageSize;

  const CustomerLoadMoreRequested({
    required this.searchTerm,
    required this.currentPage,
    required this.pageSize,
  });

  @override
  List<Object> get props => [searchTerm, currentPage, pageSize];
}

class CustomerSelected extends CustomerEvent {
  final Customer customer;

  const CustomerSelected(this.customer);

  @override
  List<Object> get props => [customer];
}

class CustomerAutocompleteRequested extends CustomerEvent {
  final String term;

  const CustomerAutocompleteRequested(this.term);

  @override
  List<Object> get props => [term];
}

class CustomerByCodeRequested extends CustomerEvent {
  final String cardCode;

  const CustomerByCodeRequested(this.cardCode);

  @override
  List<Object> get props => [cardCode];
}

class CustomerSearchCleared extends CustomerEvent {}

class CustomerSelectionCleared extends CustomerEvent {}