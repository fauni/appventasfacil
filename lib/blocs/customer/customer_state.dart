// lib/blocs/customer/customer_state.dart
import 'package:equatable/equatable.dart';
import 'package:appventas/models/customer/customer.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoadingMore extends CustomerState {
  final List<Customer> currentCustomers;
  final int currentPage;
  final String searchTerm;

  const CustomerLoadingMore({
    required this.currentCustomers,
    required this.currentPage,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [currentCustomers, currentPage, searchTerm];
}

class CustomerSearchLoaded extends CustomerState {
  final CustomerSearchResponse response;
  final String searchTerm;

  const CustomerSearchLoaded({
    required this.response,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [response, searchTerm];
}

class CustomerSearchLoadedMore extends CustomerState {
  final CustomerSearchResponse response;
  final String searchTerm;
  final List<Customer> allCustomers;

  const CustomerSearchLoadedMore({
    required this.response,
    required this.searchTerm,
    required this.allCustomers,
  });

  @override
  List<Object> get props => [response, searchTerm, allCustomers];
}

class CustomerDetailLoaded extends CustomerState {
  final Customer customer;

  const CustomerDetailLoaded(this.customer);

  @override
  List<Object> get props => [customer];
}

class CustomerAutocompleteLoaded extends CustomerState {
  final List<CustomerAutocomplete> suggestions;
  final String term;

  const CustomerAutocompleteLoaded({
    required this.suggestions,
    required this.term,
  });

  @override
  List<Object> get props => [suggestions, term];
}

class CustomerSelectedState extends CustomerState {
  final Customer customer;

  const CustomerSelectedState(this.customer);

  @override
  List<Object> get props => [customer];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object> get props => [message];
}