// lib/widgets/customer_autocomplete_field.dart
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/customer/customer_event.dart';
import 'package:appventas/blocs/customer/customer_state.dart';

class CustomerAutocompleteField extends StatefulWidget {
  final Customer? initialCustomer;
  final Function(Customer?) onCustomerSelected;
  final String? label;
  final String? hint;
  final bool isRequired;
  final bool enabled;

  const CustomerAutocompleteField({
    Key? key,
    this.initialCustomer,
    required this.onCustomerSelected,
    this.label = 'Cliente',
    this.hint = 'Buscar cliente...',
    this.isRequired = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomerAutocompleteField> createState() => _CustomerAutocompleteFieldState();
}

class _CustomerAutocompleteFieldState extends State<CustomerAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Customer? _selectedCustomer;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;
    if (_selectedCustomer != null) {
      _controller.text = _selectedCustomer!.displayText;
    }
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _showSuggestions) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _showSuggestions = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (!widget.enabled) return;
    
    setState(() {
      _showSuggestions = value.isNotEmpty;
      if (value.isEmpty) {
        _selectedCustomer = null;
        widget.onCustomerSelected(null);
      }
    });

    if (value.length >= 2) {
      context.read<CustomerBloc>().add(CustomerAutocompleteRequested(value));
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _controller.text = customer.displayText;
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onCustomerSelected(customer);
  }

  Future<void> _openCustomerSelection() async {
    final selectedCustomer = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<CustomerBloc>(),
          child: CustomerSelectionScreen(
            initialCustomer: _selectedCustomer,
          ),
        ),
      ),
    );

    if (selectedCustomer != null) {
      _selectCustomer(selectedCustomer);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedCustomer = null;
      _controller.clear();
      _showSuggestions = false;
    });
    widget.onCustomerSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              decoration: InputDecoration(
                labelText: widget.isRequired ? '${widget.label} *' : widget.label,
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.person_search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedCustomer != null && widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSelection,
                        tooltip: 'Limpiar selección',
                      ),
                    if (widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _openCustomerSelection,
                        tooltip: 'Buscar cliente',
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              onChanged: _onTextChanged,
              validator: widget.isRequired
                  ? (value) {
                      if (_selectedCustomer == null) {
                        return 'Debe seleccionar un cliente';
                      }
                      return null;
                    }
                  : null,
            ),
            
            // Customer info overlay
            if (_selectedCustomer != null)
              Positioned(
                right: widget.enabled ? 80 : 16,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Seleccionado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        
        // Customer details card
        if (_selectedCustomer != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[600],
                  child: Text(
                    _selectedCustomer!.cardCode.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCustomer!.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Código: ${_selectedCustomer!.cardCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_selectedCustomer!.licTradNum.isNotEmpty)
                        Text(
                          'NIT: ${_selectedCustomer!.licTradNum}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        // Autocomplete suggestions
        if (_showSuggestions && widget.enabled)
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerAutocompleteLoaded) {
                if (state.suggestions.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_off, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'No se encontraron clientes',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _openCustomerSelection,
                          child: const Text('Buscar más'),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ...state.suggestions.map((suggestion) {
                        // Convert CustomerAutocomplete to Customer
                        final customer = Customer(
                          cardCode: suggestion.cardCode,
                          cardName: suggestion.cardName,
                          cardFName: suggestion.cardFName,
                          cardType: 'C',
                          groupCode: 0,
                          phone1: '',
                          licTradNum: '',
                          currency: '',
                          slpCode: 0,
                          listNum: 0,
                        );

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              suggestion.cardCode.substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          title: Text(
                            suggestion.displayText,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectCustomer(customer),
                        );
                      }).toList(),
                      
                      // "Ver más" option
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: _openCustomerSelection,
                          icon: const Icon(Icons.search),
                          label: const Text('Ver todos los clientes'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}