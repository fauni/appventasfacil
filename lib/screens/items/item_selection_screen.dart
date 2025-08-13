// lib/screens/items/item_selection_screen.dart
import 'package:appventas/models/item/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/item/item_event.dart';
import 'package:appventas/blocs/item/item_state.dart';

class ItemSelectionScreen extends StatefulWidget {
  final Item? initialItem;
  final bool showStock;
  final bool validateStock;
  final double? requiredQuantity;
  
  const ItemSelectionScreen({
    Key? key,
    this.initialItem,
    this.showStock = true,
    this.validateStock = false,
    this.requiredQuantity,
  }) : super(key: key);

  @override
  State<ItemSelectionScreen> createState() => _ItemSelectionScreenState();
}

class _ItemSelectionScreenState extends State<ItemSelectionScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Item? _selectedItem;
  bool _hasSearched = false;
  String _currentView = 'search'; // 'search', 'lowStock', 'outOfStock'

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
    
    // Cargar items inicialmente
    context.read<ItemBloc>().add(const ItemSearchRequested(searchTerm: ''));
    
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
      final state = context.read<ItemBloc>().state;
      if (state is ItemSearchLoaded && state.response.hasMorePages) {
        context.read<ItemBloc>().add(ItemLoadMoreRequested(
          searchTerm: state.searchTerm,
          currentPage: state.response.pageNumber,
          pageSize: state.response.pageSize,
        ));
      } else if (state is ItemSearchLoadedMore && state.response.hasMorePages) {
        context.read<ItemBloc>().add(ItemLoadMoreRequested(
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
      _currentView = 'search';
    });
    
    if (value.isEmpty) {
      context.read<ItemBloc>().add(const ItemSearchRequested(searchTerm: ''));
    } else {
      context.read<ItemBloc>().add(ItemSearchRequested(searchTerm: value));
    }
  }

  void _selectItem(Item item) {
    // Validar stock si es necesario
    if (widget.validateStock && widget.requiredQuantity != null) {
      if (item.stock < widget.requiredQuantity!) {
        _showInsufficientStockDialog(item);
        return;
      }
    }

    setState(() {
      _selectedItem = item;
    });
    context.read<ItemBloc>().add(ItemSelected(item));
  }

  void _showInsufficientStockDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stock Insuficiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${item.displayName}'),
            Text('Stock disponible: ${item.stockDisplay}'),
            Text('Cantidad requerida: ${widget.requiredQuantity}'),
            const SizedBox(height: 16),
            const Text('No hay suficiente stock para esta cantidad.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedItem != null) {
      Navigator.of(context).pop(_selectedItem);
    }
  }

  void _showLowStock() {
    setState(() {
      _currentView = 'lowStock';
    });
    context.read<ItemBloc>().add(const ItemLowStockRequested());
  }

  void _showOutOfStock() {
    setState(() {
      _currentView = 'outOfStock';
    });
    context.read<ItemBloc>().add(const ItemOutOfStockRequested());
  }

  void _backToSearch() {
    setState(() {
      _currentView = 'search';
    });
    _onSearchChanged(_searchController.text);
  }

  Color _getStockColor(double stock) {
    if (stock <= 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    return Colors.green;
  }

  IconData _getStockIcon(double stock) {
    if (stock <= 0) return Icons.error;
    if (stock < 10) return Icons.warning;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: _currentView != 'search' 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToSearch,
              )
            : null,
        actions: [
          if (_selectedItem != null)
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
          // Barra de búsqueda y botones de stock (solo en vista de búsqueda)
          if (_currentView == 'search') ...[
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
                      hintText: 'Buscar por código o nombre del item...',
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
                  
                  // Botones de stock (solo si showStock está habilitado)
                  if (widget.showStock) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showLowStock,
                            icon: const Icon(Icons.warning, size: 16),
                            label: const Text('Stock Bajo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade50,
                              foregroundColor: Colors.orange.shade700,
                              side: BorderSide(color: Colors.orange.shade200),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showOutOfStock,
                            icon: const Icon(Icons.error, size: 16),
                            label: const Text('Sin Stock'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Item seleccionado
                  if (_selectedItem != null) ...[
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
                                  'Item seleccionado:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                Text(
                                  _selectedItem!.displayText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                if (widget.showStock)
                                  Text(
                                    'Stock: ${_selectedItem!.stockDisplay}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getStockColor(_selectedItem!.stock),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedItem = null;
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
          ],

          // Lista de items
          Expanded(
            child: BlocBuilder<ItemBloc, ItemState>(
              builder: (context, state) {
                if (state is ItemLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ItemError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentView == 'search') {
                              _onSearchChanged(_searchController.text);
                            } else if (_currentView == 'lowStock') {
                              _showLowStock();
                            } else if (_currentView == 'outOfStock') {
                              _showOutOfStock();
                            }
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Mostrar resultados de búsqueda normal
                if ((state is ItemSearchLoaded || state is ItemSearchLoadedMore) && _currentView == 'search') {
                  final response = state is ItemSearchLoaded 
                      ? state.response 
                      : (state as ItemSearchLoadedMore).response;
                      
                  if (response.items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron items',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildItemList(response.items, response.hasMorePages);
                }

                // Mostrar items con stock bajo
                if (state is ItemLowStockLoaded && _currentView == 'lowStock') {
                  if (state.lowStockItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'No hay items con stock bajo',
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildItemList(state.lowStockItems, false);
                }

                // Mostrar items sin stock
                if (state is ItemOutOfStockLoaded && _currentView == 'outOfStock') {
                  if (state.outOfStockItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'No hay items sin stock',
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildItemList(state.outOfStockItems, false);
                }

                // Estado inicial
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Busca items o explora por stock',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedItem != null
          ? FloatingActionButton.extended(
              onPressed: _confirmSelection,
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar'),
            )
          : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case 'lowStock':
        return 'Items con Stock Bajo';
      case 'outOfStock':
        return 'Items Sin Stock';
      default:
        return 'Seleccionar Item';
    }
  }

  Widget _buildItemList(List<Item> items, bool hasMore) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = items[index];
        final isSelected = _selectedItem?.itemCode == item.itemCode;
        final stockColor = widget.showStock ? _getStockColor(item.stock) : Colors.grey;
        final stockIcon = widget.showStock ? _getStockIcon(item.stock) : Icons.inventory_2;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.blue[600]!, width: 2)
                : null,
          ),
          child: Card(
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? Colors.blue[600]
                    : (widget.showStock ? stockColor.withOpacity(0.1) : Colors.grey[300]),
                child: Icon(
                  widget.showStock ? stockIcon : Icons.inventory_2,
                  color: isSelected 
                      ? Colors.white 
                      : (widget.showStock ? stockColor : Colors.grey[600]),
                  size: 20,
                ),
              ),
              title: Text(
                item.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue[700] : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código: ${item.itemCode}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (widget.showStock) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 14,
                          color: stockColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${item.stockDisplay}',
                          style: TextStyle(
                            color: stockColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.validateStock && widget.requiredQuantity != null && item.stock < widget.requiredQuantity!) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Insuficiente',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  Text(
                    'UGP Entry: ${item.ugpEntry}',
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
              onTap: () => _selectItem(item),
            ),
          ),
        );
      },
    );
  }
}