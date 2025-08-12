import 'package:appventas/blocs/sales_orders/sales_orders_bloc.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_event.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_state.dart';
import 'package:appventas/models/sales_order/sales_order_search_request.dart';
import 'package:appventas/screens/sales_order/sales_order_detail_screen.dart';
import 'package:appventas/widgets/sales_order/sales_order_card.dart';
import 'package:appventas/widgets/sales_order/sales_order_search_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesOrdersListScreen extends StatefulWidget {
  const SalesOrdersListScreen({Key? key}) : super(key: key);

  @override
  State<SalesOrdersListScreen> createState() => _SalesOrdersListScreenState();
}

class _SalesOrdersListScreenState extends State<SalesOrdersListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showFilters = false;
  SalesOrderSearchRequest _currentFilters = const SalesOrderSearchRequest();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar órdenes al iniciar
    context.read<SalesOrdersBloc>().add(SalesOrdersLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final bloc = context.read<SalesOrdersBloc>();
      final state = bloc.state;
      
      if (state is SalesOrdersLoaded && state.response.hasNextPage) {
        bloc.add(SalesOrdersLoadMoreRequested(state.currentRequest));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch() {
    final searchTerm = _searchController.text.trim();
    final newFilters = _currentFilters.copyWith(
      searchTerm: searchTerm,
      pageNumber: 1,
    );
    
    context.read<SalesOrdersBloc>().add(SalesOrdersSearchRequested(newFilters));
  }

  void _onFiltersApplied(SalesOrderSearchRequest filters) {
    setState(() {
      _currentFilters = filters;
      _showFilters = false;
    });
    
    context.read<SalesOrdersBloc>().add(SalesOrdersFilterChanged(filters));
  }

  void _onRefresh() {
    context.read<SalesOrdersBloc>().add(SalesOrdersRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Venta'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por número, cliente...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          
          // Filtros (mostrar/ocultar)
          if (_showFilters)
            SalesOrderSearchFilters(
              initialFilters: _currentFilters,
              onFiltersApplied: _onFiltersApplied,
            ),
          
          // Lista de órdenes
          Expanded(
            child: BlocBuilder<SalesOrdersBloc, SalesOrdersState>(
              builder: (context, state) {
                if (state is SalesOrdersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is SalesOrdersError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar órdenes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is SalesOrdersEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay órdenes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is SalesOrdersLoaded || state is SalesOrdersLoadingMore) {
                  final response = state is SalesOrdersLoaded 
                      ? state.response 
                      : (state as SalesOrdersLoadingMore).currentResponse;
                  
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: response.orders.length + (state is SalesOrdersLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= response.orders.length) {
                          // Mostrar indicador de carga al final
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final order = response.orders[index];
                        return SalesOrderCard(
                          order: order,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SalesOrderDetailScreen(
                                  docEntry: order.docEntry,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}