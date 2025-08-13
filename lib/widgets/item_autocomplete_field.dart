// lib/widgets/item_autocomplete_field.dart
import 'package:appventas/models/item/item.dart';
import 'package:appventas/screens/items/item_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/item/item_event.dart';
import 'package:appventas/blocs/item/item_state.dart';

class ItemAutocompleteField extends StatefulWidget {
  final Item? initialItem;
  final Function(Item?) onItemSelected;
  final String? label;
  final String? hint;
  final bool isRequired;
  final bool enabled;

  const ItemAutocompleteField({
    Key? key,
    this.initialItem,
    required this.onItemSelected,
    this.label = 'Item',
    this.hint = 'Buscar item...',
    this.isRequired = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ItemAutocompleteField> createState() => _ItemAutocompleteFieldState();
}

class _ItemAutocompleteFieldState extends State<ItemAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Item? _selectedItem;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
    if (_selectedItem != null) {
      _controller.text = _selectedItem!.displayText;
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
        _selectedItem = null;
        widget.onItemSelected(null);
      }
    });

    if (value.length >= 2) {
      context.read<ItemBloc>().add(ItemAutocompleteRequested(value));
    }
  }

  void _selectItem(Item item) {
    setState(() {
      _selectedItem = item;
      _controller.text = item.displayText;
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onItemSelected(item);
  }

  Future<void> _openItemSelection() async {
    final selectedItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ItemBloc>(),
          child: ItemSelectionScreen(
            initialItem: _selectedItem,
          ),
        ),
      ),
    );

    if (selectedItem != null) {
      _selectItem(selectedItem);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedItem = null;
      _controller.clear();
      _showSuggestions = false;
    });
    widget.onItemSelected(null);
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
                prefixIcon: const Icon(Icons.inventory_2),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedItem != null && widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSelection,
                        tooltip: 'Limpiar selección',
                      ),
                    if (widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _openItemSelection,
                        tooltip: 'Buscar item',
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
                      if (_selectedItem == null) {
                        return 'Debe seleccionar un item';
                      }
                      return null;
                    }
                  : null,
            ),
            
            // Item info overlay
            if (_selectedItem != null)
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
        
        // Item details card
        if (_selectedItem != null)
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
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedItem!.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Código: ${_selectedItem!.itemCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'UGP Entry: ${_selectedItem!.ugpEntry}',
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
          BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemAutocompleteLoaded) {
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
                          'No se encontraron items',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _openItemSelection,
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
                        // Convert ItemAutocomplete to Item
                        final item = Item(
                          itemCode: suggestion.itemCode,
                          itemName: suggestion.itemName,
                          ugpEntry: suggestion.ugpEntry,
                          stock: suggestion.stock
                        );

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue[100],
                            child: const Icon(
                              Icons.inventory_2,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            suggestion.displayText,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            'UGP: ${suggestion.ugpEntry}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () => _selectItem(item),
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
                          onPressed: _openItemSelection,
                          icon: const Icon(Icons.search),
                          label: const Text('Ver todos los items'),
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