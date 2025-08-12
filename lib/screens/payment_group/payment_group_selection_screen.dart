import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/customer/customer_event.dart';
import 'package:appventas/blocs/payment_group/payment_group_bloc.dart';
import 'package:appventas/blocs/payment_group/payment_group_event.dart';
import 'package:appventas/blocs/payment_group/payment_group_state.dart';
import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentGroupSelectionScreen extends StatefulWidget {
  final PaymentGroup? initialPaymentGroup;

  const PaymentGroupSelectionScreen({
    Key? key,
    this.initialPaymentGroup
  }): super(key: key);

  @override
  State<PaymentGroupSelectionScreen> createState() => _PaymentGroupSelectionScreenState();
}

class _PaymentGroupSelectionScreenState extends State<PaymentGroupSelectionScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  PaymentGroup? _selectedPaymentGroup;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentGroup = widget.initialPaymentGroup;

    // Cargar PaymentGroup inicialmente
    context.read<PaymentGroupBloc>().add(const PaymentGroupSearchRequested());

    // Listener para scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll(){
    if(_isBottom){
      final state = context.read<PaymentGroupBloc>().state;
      if(state is PaymentGroupSearchLoaded && state.response.hasMorePages){
        context.read<PaymentGroupBloc>().add(PaymentGroupLoadMoreRequested(
          searchTerm: _searchController.text,
          currentPage: state.response.pageNumber,
          pageSize: state.response.pageSize,
        ));
      } else if(state is PaymentGroupSearchLoadedMore && state.response.hasMorePages){
        context.read<CustomerBloc>().add(CustomerLoadMoreRequested(searchTerm: state.searchTerm, currentPage: state.response.pageNumber, pageSize: state.response.pageSize));
      }
    }
  }

  bool get _isBottom {
    if(!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _hasSearched = value.isNotEmpty;
    }); 

    if (value.isEmpty) {
      context.read<PaymentGroupBloc>().add(const PaymentGroupSearchRequested());
    } else {
      context.read<PaymentGroupBloc>().add(PaymentGroupSearchRequested(searchTerm: value));
    }
  }

  void _selectPaymentGroup(PaymentGroup paymentGroup){
    setState(() {
      _selectedPaymentGroup = paymentGroup;
    });
    context.read<PaymentGroupBloc>().add(PaymentGroupSelected(paymentGroup));
  }

  void _confirmSelection() {
    if (_selectedPaymentGroup != null) {
      Navigator.of(context).pop(_selectedPaymentGroup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}