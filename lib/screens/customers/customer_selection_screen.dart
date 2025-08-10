// lib/screens/customer_selection_screen.dart
import 'package:appventas/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/customer/customer_event.dart';
import 'package:appventas/blocs/customer/customer_state.dart';

class CustomerSelectionScreen extends StatefulWidget {
  final Customer? initialCustomer;
  
  const CustomerSelectionScreen({
    Key? key,
    this.initialCustomer,
  }) : super(key: key);

  @override
  State<CustomerSelectionScreen> createState() => _CustomerSelectionScreenState();
}

class _CustomerSelectionScreenState extends State<CustomerSelectionScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Customer? _selectedCustomer;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;
    
    // Cargar clientes inicialmente
    context.read<CustomerBloc>().add(const CustomerSearchRequested());
    
    // Listener para scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<CustomerBloc>().state;
      if (state is CustomerSearchLoaded && state.response.hasMorePages) {
        context.read<CustomerBloc>().add(CustomerLoadMoreRequested(
          searchTerm: state.searchTerm,
          currentPage: state.response.pageNumber,
          pageSize: state.response.pageSize,
        ));
      } else if (state is CustomerSearchLoadedMore && state.response.hasMorePages) {
        context.read<CustomerBloc>().add(CustomerLoadMoreRequested(
          searchTerm: state.searchTerm,
          currentPage: state.response.pageNumber,
          pageSize: state.response.pageSize,
        ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _hasSearched = value.isNotEmpty;
    });
    
    if (value.isEmpty) {
      context.read<CustomerBloc>().add(const CustomerSearchRequested());
    } else {
      context.read<CustomerBloc>().add(CustomerSearchRequested(searchTerm: value));
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
    });
    context.read<CustomerBloc>().add(CustomerSelected(customer));
  }

  void _confirmSelection() {
    if (_selectedCustomer != null) {
      Navigator.of(context).pop(_selectedCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Seleccionar Cliente'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_selectedCustomer != null)
            TextButton(
              onPressed: _confirmSelection,
              child: const Text(
                'SELECCIONAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por código, nombre o razón social...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue[600]!),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                if (_selectedCustomer != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente seleccionado:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                              Text(
                                _selectedCustomer!.displayText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedCustomer = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Lista de clientes
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading && !_hasSearched) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando clientes...'),
                      ],
                    ),
                  );
                }

                if (state is CustomerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar clientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CustomerBloc>().add(
                              CustomerSearchRequested(searchTerm: _searchController.text),
                            );
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                List<Customer> customers = [];
                bool isLoadingMore = false;
                bool hasMorePages = false;

                if (state is CustomerSearchLoaded) {
                  customers = state.response.customers;
                  hasMorePages = state.response.hasMorePages;
                } else if (state is CustomerSearchLoadedMore) {
                  customers = state.allCustomers;
                  hasMorePages = state.response.hasMorePages;
                } else if (state is CustomerLoadingMore) {
                  customers = state.currentCustomers;
                  isLoadingMore = true;
                }

                if (customers.isEmpty && _hasSearched) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron clientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otros términos de búsqueda',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: customers.length + (hasMorePages || isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == customers.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final customer = customers[index];
                    final isSelected = _selectedCustomer?.cardCode == customer.cardCode;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: isSelected ? 8 : 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.blue[600]!, width: 2)
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.blue[600]
                                : Colors.grey[300],
                            child: Text(
                              customer.cardCode.substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue[700] : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Código: ${customer.cardCode}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (customer.phone1.isNotEmpty)
                                Text(
                                  'Teléfono: ${customer.phone1}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              if (customer.licTradNum.isNotEmpty)
                                Text(
                                  'NIT: ${customer.licTradNum}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue[600],
                                  size: 28,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey[400],
                                  size: 28,
                                ),
                          onTap: () => _selectCustomer(customer),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedCustomer != null
          ? FloatingActionButton.extended(
              onPressed: _confirmSelection,
              backgroundColor: Colors.blue[600],
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}