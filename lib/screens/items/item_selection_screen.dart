// lib/screens/items/item_selection_screen.dart
import 'package:appventas/models/item/item.dart';
import 'package:appventas/widgets/warehouse_stock_button.dart';
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

  String _getAppBarTitle() {
    switch (_currentView) {
      case 'lowStock':
        return 'Items con Stock Bajo';
      case 'outOfStock':
        return 'Items sin Stock';
      default:
        return 'Seleccionar Item';
    }
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
                  // if (widget.showStock) ...[
                  //   const SizedBox(height: 12),
                  //   Row(
                  //     children: [
                  //       Expanded(
                  //         child: ElevatedButton.icon(
                  //           onPressed: _showLowStock,
                  //           icon: const Icon(Icons.warning, size: 16),
                  //           label: const Text('Stock Bajo'),
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: Colors.orange.shade50,
                  //             foregroundColor: Colors.orange.shade700,
                  //             side: BorderSide(color: Colors.orange.shade200),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 8),
                  //       Expanded(
                  //         child: ElevatedButton.icon(
                  //           onPressed: _showOutOfStock,
                  //           icon: const Icon(Icons.error, size: 16),
                  //           label: const Text('Sin Stock'),
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: Colors.red.shade50,
                  //             foregroundColor: Colors.red.shade700,
                  //             side: BorderSide(color: Colors.red.shade200),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],

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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar items',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_currentView == 'search') {
                              context.read<ItemBloc>().add(
                                ItemSearchRequested(searchTerm: _searchController.text),
                              );
                            } else if (_currentView == 'lowStock') {
                              context.read<ItemBloc>().add(const ItemLowStockRequested());
                            } else if (_currentView == 'outOfStock') {
                              context.read<ItemBloc>().add(const ItemOutOfStockRequested());
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Estados con datos de items
                List<Item> items = [];
                bool isLoadingMore = false;
                bool hasMorePages = false;

                if (state is ItemSearchLoaded) {
                  items = state.response.items;
                  hasMorePages = state.response.hasMorePages;
                } else if (state is ItemSearchLoadedMore) {
                  items = state.allItems;
                  hasMorePages = state.response.hasMorePages;
                } else if (state is ItemLoadingMore) {
                  items = state.currentItems;
                  isLoadingMore = true;
                }

                if (items.isEmpty) {
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
                        Text(
                          _getEmptyMessage(),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getEmptySubtitle(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_currentView == 'search') {
                      context.read<ItemBloc>().add(
                        ItemSearchRequested(searchTerm: _searchController.text),
                      );
                    } else if (_currentView == 'lowStock') {
                      context.read<ItemBloc>().add(const ItemLowStockRequested());
                    } else if (_currentView == 'outOfStock') {
                      context.read<ItemBloc>().add(const ItemOutOfStockRequested());
                    }
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return _buildItemCard(items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_currentView) {
      case 'lowStock':
        return 'No hay items con stock bajo';
      case 'outOfStock':
        return 'No hay items sin stock';
      default:
        return _hasSearched ? 'No se encontraron items' : 'No hay items disponibles';
    }
  }

  String _getEmptySubtitle() {
    switch (_currentView) {
      case 'lowStock':
        return 'Todos los items tienen stock suficiente';
      case 'outOfStock':
        return 'Todos los items tienen stock disponible';
      default:
        return _hasSearched 
            ? 'Intenta con otros términos de búsqueda'
            : 'Intenta realizar una búsqueda';
    }
  }

  Widget _buildItemCard(Item item) {
    final isSelected = _selectedItem?.itemCode == item.itemCode;
    final hasRequiredStock = widget.requiredQuantity == null || 
                            item.stock >= widget.requiredQuantity!;

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con código y nombre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.itemCode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Nombre del item
              Text(
                item.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Stock information y botón de stock por almacenes
              Row(
                children: [
                  Icon(
                    _getStockIcon(item.stock),
                    color: _getStockColor(item.stock),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stock: ${item.stockDisplay}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getStockColor(item.stock),
                    ),
                  ),
                  const Spacer(),
                  // Botón compacto para ver stock por almacenes
                  CompactWarehouseStockButton(
                    itemCode: item.itemCode,
                    itemName: item.itemName,
                    currentStock: item.stock,
                  ),
                ],
              ),
              
              // Advertencia de stock insuficiente
              if (widget.validateStock && widget.requiredQuantity != null && !hasRequiredStock) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red[600],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Stock insuficiente (Requerido: ${widget.requiredQuantity!.toStringAsFixed(2)})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}