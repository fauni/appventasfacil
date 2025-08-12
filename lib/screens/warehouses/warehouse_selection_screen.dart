// lib/screens/warehouse/warehouse_selection_screen.dart
import 'package:appventas/blocs/warehouse/warehouse_bloc.dart';
import 'package:appventas/blocs/warehouse/warehouse_event.dart';
import 'package:appventas/blocs/warehouse/warehouse_state.dart';
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WarehouseSelectionScreen extends StatefulWidget {
  final Warehouse? selectedWarehouse;
  final String title;

  const WarehouseSelectionScreen({
    Key? key,
    this.selectedWarehouse,
    this.title = 'Seleccionar Almacén',
  }) : super(key: key);

  @override
  State<WarehouseSelectionScreen> createState() => _WarehouseSelectionScreenState();
}

class _WarehouseSelectionScreenState extends State<WarehouseSelectionScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Warehouse? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _selectedWarehouse = widget.selectedWarehouse;
    
    // Cargar almacenes iniciales
    context.read<WarehouseBloc>().add(const WarehousesLoadRequested());
    
    // Configurar scroll infinito
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
      context.read<WarehouseBloc>().add(const WarehousesLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      context.read<WarehouseBloc>().add(const WarehousesLoadRequested());
    } else {
      context.read<WarehouseBloc>().add(WarehousesSearchTermChanged(value.trim()));
    }
  }

  void _selectWarehouse(Warehouse warehouse) {
    setState(() {
      _selectedWarehouse = warehouse;
    });
  }

  void _confirmSelection() {
    if (_selectedWarehouse != null) {
      Navigator.of(context).pop(_selectedWarehouse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_selectedWarehouse != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmSelection,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: BlocBuilder<WarehouseBloc, WarehouseState>(
              builder: (context, state) {
                return _buildBody(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedWarehouse != null
          ? FloatingActionButton(
              onPressed: _confirmSelection,
              child: const Icon(Icons.check),
            )
          : null,
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Buscar almacén',
          hintText: 'Código o nombre del almacén',
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
          border: const OutlineInputBorder(),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildBody(WarehouseState state) {
    if (state is WarehouseLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is WarehouseError) {
      return _buildErrorState(state.message);
    }
    
    if (state is WarehouseEmpty) {
      return _buildEmptyState(state.message);
    }
    
    if (state is WarehousesLoaded) {
      return _buildWarehouseList(state.warehouses, false);
    }
    
    if (state is WarehousesSearchLoaded) {
      return _buildWarehouseList(
        state.response.warehouses, 
        state.response.hasNextPage,
      );
    }
    
    if (state is WarehouseLoadingMore && state is WarehousesSearchLoaded) {
      final searchState = state as WarehousesSearchLoaded;
      return _buildWarehouseList(
        searchState.response.warehouses, 
        true,
      );
    }
    
    return const Center(child: Text('Cargando almacenes...'));
  }

  Widget _buildWarehouseList(List<Warehouse> warehouses, bool hasNextPage) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WarehouseBloc>().add(const WarehousesRefreshRequested());
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: warehouses.length + (hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == warehouses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final warehouse = warehouses[index];
          final isSelected = _selectedWarehouse?.whsCode == warehouse.whsCode;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                child: Icon(
                  Icons.warehouse,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
              title: Text(
                warehouse.whsCode,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(warehouse.whsName),
              trailing: isSelected 
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectWarehouse(warehouse),
              selected: isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar almacenes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<WarehouseBloc>().add(const WarehousesRefreshRequested());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay almacenes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<WarehouseBloc>().add(const WarehousesRefreshRequested());
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}