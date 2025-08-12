import 'package:appventas/models/sales_order/sales_order_search_request.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesOrderSearchFilters extends StatefulWidget {
  final SalesOrderSearchRequest initialFilters;
  final Function(SalesOrderSearchRequest) onFiltersApplied;

  const SalesOrderSearchFilters({
    Key? key,
    required this.initialFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<SalesOrderSearchFilters> createState() => _SalesOrderSearchFiltersState();
}

class _SalesOrderSearchFiltersState extends State<SalesOrderSearchFilters> {
  late TextEditingController _cardCodeController;
  late TextEditingController _slpCodeController;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _docStatus;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _cardCodeController = TextEditingController(text: widget.initialFilters.cardCode ?? '');
    _slpCodeController = TextEditingController(
      text: widget.initialFilters.slpCode?.toString() ?? '',
    );
    _dateFrom = widget.initialFilters.dateFrom;
    _dateTo = widget.initialFilters.dateTo;
    _docStatus = widget.initialFilters.docStatus;
  }

  @override
  void dispose() {
    _cardCodeController.dispose();
    _slpCodeController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final slpCode = _slpCodeController.text.trim().isNotEmpty 
        ? int.tryParse(_slpCodeController.text.trim()) 
        : null;
    
    final filters = SalesOrderSearchRequest(
      searchTerm: widget.initialFilters.searchTerm,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      cardCode: _cardCodeController.text.trim().isNotEmpty 
          ? _cardCodeController.text.trim() 
          : null,
      slpCode: slpCode,
      docStatus: _docStatus,
      pageSize: widget.initialFilters.pageSize,
      pageNumber: 1, // Reset to first page
    );
    
    widget.onFiltersApplied(filters);
  }

  void _clearFilters() {
    setState(() {
      _cardCodeController.clear();
      _slpCodeController.clear();
      _dateFrom = null;
      _dateTo = null;
      _docStatus = null;
    });
    
    final filters = SalesOrderSearchRequest(
      searchTerm: widget.initialFilters.searchTerm,
      pageSize: widget.initialFilters.pageSize,
      pageNumber: 1,
    );
    
    widget.onFiltersApplied(filters);
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isFrom 
          ? (_dateFrom ?? DateTime.now()) 
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (selectedDate != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = selectedDate;
        } else {
          _dateTo = selectedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cliente
            TextField(
              controller: _cardCodeController,
              decoration: const InputDecoration(
                labelText: 'Código de Cliente',
                hintText: 'Ej: C001',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Vendedor
            TextField(
              controller: _slpCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Código de Vendedor',
                hintText: 'Ej: 1',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Estado del documento
            DropdownButtonFormField<String>(
              value: _docStatus,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'O', child: Text('Abierta')),
                DropdownMenuItem(value: 'C', child: Text('Cerrada')),
              ],
              onChanged: (value) {
                setState(() {
                  _docStatus = value;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Fechas
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha Desde',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateFrom != null 
                            ? _dateFormat.format(_dateFrom!) 
                            : 'Seleccionar',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha Hasta',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateTo != null 
                            ? _dateFormat.format(_dateTo!) 
                            : 'Seleccionar',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}