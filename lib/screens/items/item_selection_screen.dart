// lib/screens/item_selection_screen.dart
import 'package:appventas/models/item/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/item/item_event.dart';
import 'package:appventas/blocs/item/item_state.dart';

class ItemSelectionScreen extends StatefulWidget {
  final Item? initialItem;
  
  const ItemSelectionScreen({
    Key? key,
    this.initialItem,
  }) : super(key: key);

  @override
  State<ItemSelectionScreen> createState() => _ItemSelectionScreenState();
}

class _ItemSelectionScreenState extends State<ItemSelectionScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Item? _selectedItem;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
    
    // Cargar items inicialmente
    context.read<ItemBloc>().add(const ItemSearchRequested());
    
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
    });
    
    if (value.isEmpty) {
      context.read<ItemBloc>().add(const ItemSearchRequested());
    } else {
      context.read<ItemBloc>().add(ItemSearchRequested(searchTerm: value));
    }
  }

  void _selectItem(Item item) {
    setState(() {
      _selectedItem = item;
    });
    context.read<ItemBloc>().add(ItemSelected(item));
  }

  void _confirmSelection() {
    if (_selectedItem != null) {
      Navigator.of(context).pop(_selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Item'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
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
          
          // Lista de items
          Expanded(
            child: BlocBuilder<ItemBloc, ItemState>(
              builder: (context, state) {
                if (state is ItemLoading && !_hasSearched) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando items...'),
                      ],
                    ),
                  );
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
                            context.read<ItemBloc>().add(
                              ItemSearchRequested(searchTerm: _searchController.text),
                            );
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

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

                if (items.isEmpty && _hasSearched) {
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
                          'No se encontraron items',
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
                  itemCount: items.length + (hasMorePages || isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final item = items[index];
                    final isSelected = _selectedItem?.itemCode == item.itemCode;

                    return Card(
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
                            child: Icon(
                              Icons.inventory_2,
                              color: isSelected ? Colors.white : Colors.grey[600],
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
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedItem != null
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