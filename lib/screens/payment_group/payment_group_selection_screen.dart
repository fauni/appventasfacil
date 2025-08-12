import 'package:appventas/blocs/payment_group/payment_group_bloc.dart';
import 'package:appventas/blocs/payment_group/payment_group_event.dart';
import 'package:appventas/blocs/payment_group/payment_group_state.dart';
import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentGroupSelectionScreen extends StatefulWidget {
  final PaymentGroup? initialPaymentGroup;

  const PaymentGroupSelectionScreen({
    Key? key,
    this.initialPaymentGroup
  }) : super(key: key);

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

    // Cargar PaymentGroups inicialmente
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

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<PaymentGroupBloc>().state;
      if (state is PaymentGroupSearchLoaded && state.response.hasMorePages) {
        context.read<PaymentGroupBloc>().add(PaymentGroupLoadMoreRequested(
          searchTerm: _searchController.text,
          currentPage: state.response.pageNumber,
          pageSize: state.response.pageSize,
        ));
      } else if (state is PaymentGroupSearchLoadedMore && state.response.hasMorePages) {
        context.read<PaymentGroupBloc>().add(PaymentGroupLoadMoreRequested(
          searchTerm: state.searchTerm, 
          currentPage: state.response.pageNumber, 
          pageSize: state.response.pageSize
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
      context.read<PaymentGroupBloc>().add(const PaymentGroupSearchRequested());
    } else {
      context.read<PaymentGroupBloc>().add(PaymentGroupSearchRequested(searchTerm: value));
    }
  }

  void _selectPaymentGroup(PaymentGroup paymentGroup) {
    setState(() {
      _selectedPaymentGroup = paymentGroup;
    });
    // No disparamos el evento PaymentGroupSelected aquí para evitar conflictos
  }

  void _confirmSelection() {
    if (_selectedPaymentGroup != null) {
      Navigator.of(context).pop(_selectedPaymentGroup);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedPaymentGroup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Condición de Pago'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedPaymentGroup != null)
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar selección',
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar condición de pago...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Mostrar selección actual
          if (_selectedPaymentGroup != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionado: Grupo ${_selectedPaymentGroup!.groupNum}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_selectedPaymentGroup!.pymntGroup),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Lista de payment groups
          Expanded(
            child: BlocBuilder<PaymentGroupBloc, PaymentGroupState>(
              builder: (context, state) {
                if (state is PaymentGroupLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is PaymentGroupError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar condiciones de pago',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<PaymentGroupBloc>().add(
                              PaymentGroupSearchRequested(searchTerm: _searchController.text)
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                List<PaymentGroup> paymentGroups = [];
                bool hasMorePages = false;
                bool isLoadingMore = false;

                if (state is PaymentGroupSearchLoaded) {
                  paymentGroups = state.response.paymentGroups;
                  hasMorePages = state.response.hasMorePages;
                } else if (state is PaymentGroupSearchLoadedMore) {
                  paymentGroups = state.allPaymentGroups;
                  hasMorePages = state.response.hasMorePages;
                } else if (state is PaymentGroupLoadingMore) {
                  paymentGroups = state.currentPaymentGroups;
                  isLoadingMore = true;
                }

                if (paymentGroups.isEmpty && !_hasSearched) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay condiciones de pago disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (paymentGroups.isEmpty && _hasSearched) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otros términos de búsqueda',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: paymentGroups.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= paymentGroups.length) {
                      // Loading more indicator
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final paymentGroup = paymentGroups[index];
                    final isSelected = _selectedPaymentGroup?.groupNum == paymentGroup.groupNum;
                    final isInitial = widget.initialPaymentGroup?.groupNum == paymentGroup.groupNum;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      elevation: isSelected ? 4 : 1,
                      child: InkWell(
                        onTap: () => _selectPaymentGroup(paymentGroup),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                            color: isSelected
                                ? Colors.blue.shade50
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Radio button indicator
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey,
                                    width: 2,
                                  ),
                                  color: isSelected ? Colors.blue : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              
                              // Payment group info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Grupo ${paymentGroup.groupNum}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.blue.shade700 : null,
                                          ),
                                        ),
                                        if (isInitial && !isSelected) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.orange.shade300),
                                            ),
                                            child: Text(
                                              'Actual',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      paymentGroup.pymntGroup,
                                      style: TextStyle(
                                        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade700,
                                      ),
                                    ),
                                    if (paymentGroup.listNum > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Lista: ${paymentGroup.listNum}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Arrow indicator
                              Icon(
                                Icons.chevron_right,
                                color: isSelected ? Colors.blue : Colors.grey,
                              ),
                            ],
                          ),
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
      
      // Bottom action buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedPaymentGroup != null ? _confirmSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}