// lib/screens/create_quotation_screen_with_uom.dart
// Versión actualizada con selección de unidades de medida
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_event.dart';
import 'package:appventas/blocs/quotations/quotations_state.dart';
import 'package:appventas/blocs/uom/uom_bloc.dart';
import 'package:appventas/blocs/uom/uom_event.dart';
import 'package:appventas/models/quotation/quotation_line_item.dart';
import 'package:appventas/models/sales_quotation_dto.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:appventas/widgets/uom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({Key? key}) : super(key: key);

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _salesPersonController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _offerValidityController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  List<QuotationLineItem> _documentLines = [];
  bool _isLoading = false;
  Customer? _selectedCustomer;

  @override
  void dispose() {
    _commentsController.dispose();
    _salesPersonController.dispose();
    _deliveryTimeController.dispose();
    _offerValidityController.dispose();
    _paymentMethodController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _addNewLine() {
    setState(() {
      _documentLines.add(QuotationLineItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemCode: '',
        quantity: 1.0,
        priceAfterVAT: 0.0,
        selectedUom: null,
      ));
    });
  }

  void _removeLine(int index) {
    final lineItem = _documentLines[index];
    
    // Limpiar UoM cache para este item si se elimina la línea
    if (lineItem.itemCode.isNotEmpty) {
      context.read<UomBloc>().add(UomCleared(itemCode: lineItem.itemCode));
    }
    
    setState(() {
      _documentLines.removeAt(index);
    });
  }

  Future<void> _selectCustomer() async {
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
      setState(() {
        _selectedCustomer = selectedCustomer;
      });
    }
  }

  void _createQuotation() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomer == null) {
        _showErrorMessage('Debe seleccionar un cliente');
        return;
      }

      if (_documentLines.isEmpty) {
        _showErrorMessage('Debe agregar al menos una línea de producto');
        return;
      }

      // Validar que todas las líneas tengan datos completos
      for (int i = 0; i < _documentLines.length; i++) {
        final line = _documentLines[i];
        if (line.itemCode.isEmpty || line.quantity <= 0 || line.priceAfterVAT < 0) {
          _showErrorMessage('Complete todos los datos de la línea ${i + 1}');
          return;
        }
        if (line.selectedUom == null) {
          _showErrorMessage('Seleccione la unidad de medida para la línea ${i + 1}');
          return;
        }
      }

      final quotationDto = SalesQuotationDto(
        cardCode: _selectedCustomer!.cardCode,
        comments: _commentsController.text.trim(),
        salesPersonCode: int.tryParse(_salesPersonController.text) ?? 1,
        uUsrventafacil: 'APP_FLUTTER',
        uVfTiempoEntrega: _deliveryTimeController.text.trim(),
        uVfValidezOferta: _offerValidityController.text.trim(),
        uVfFormaPago: _paymentMethodController.text.trim(),
        uFecharegistroapp: DateTime.now(),
        uHoraregistroapp: DateTime.now(),
        documentLines: _documentLines.map((line) => SalesQuotationLineDto(
          itemCode: line.itemCode,
          quantity: line.quantity,
          priceAfterVAT: line.priceAfterVAT,
          uomEntry: line.selectedUom!.uomEntry,
        )).toList(),
      );

      context.read<QuotationsBloc>().add(QuotationCreateRequested(quotationDto));
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  double _calculateTotal() {
    return _documentLines.fold(0.0, (sum, line) => sum + (line.quantity * line.priceAfterVAT));
  }

  void _onItemCodeChanged(int index, String itemCode) {
    setState(() {
      _documentLines[index] = _documentLines[index].copyWith(
        itemCode: itemCode,
        selectedUom: null, // Reset UoM when item changes
      );
    });

    // Cargar UoMs para el nuevo item si no está vacío
    if (itemCode.isNotEmpty) {
      context.read<UomBloc>().add(UomLoadRequested(itemCode));
    }
  }

  void _onUomChanged(int index, UnitOfMeasure? uom) {
    setState(() {
      _documentLines[index] = _documentLines[index].copyWith(selectedUom: uom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cotización'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _createQuotation,
              child: const Text(
                'CREAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: BlocListener<QuotationsBloc, QuotationsState>(
        listener: (context, state) {
          if (state is QuotationsLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
    
          if (state is QuotationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cotización creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is QuotationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Total Section (Fixed at top)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total de la Cotización',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                            Text(
                              'Bs. ${NumberFormat('#,##0.00').format(_calculateTotal())}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_documentLines.length} productos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
    
                  // Form Content (Scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer Selection
                          _buildSectionHeader('Seleccionar Cliente'),
                          _buildCustomerSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Header Information
                          _buildSectionHeader('Información General'),
                          _buildGeneralInfoSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Additional Fields
                          _buildSectionHeader('Términos y Condiciones'),
                          _buildTermsSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Location (Optional)
                          _buildSectionHeader('Ubicación (Opcional)'),
                          _buildLocationSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Document Lines
                          _buildSectionHeader('Productos de la Cotización'),
                          _buildDocumentLinesSection(),
                          
                          const SizedBox(height: 100), // Space for floating button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Creando cotización...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addNewLine,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: InkWell(
        onTap: _selectCustomer,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: _selectedCustomer == null 
                ? Border.all(color: Colors.red.withOpacity(0.5))
                : null,
          ),
          child: _selectedCustomer == null
              ? Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: Colors.grey[600],
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar Cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Toca para buscar y seleccionar un cliente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    ),
                  ],
                )
              : Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[600],
                      child: Text(
                        _selectedCustomer!.cardCode.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCustomer!.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Código: ${_selectedCustomer!.cardCode}',
                            style: TextStyle(
                              fontSize: 14,
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
                    Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cambiar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _salesPersonController,
              decoration: InputDecoration(
                labelText: 'Código de Vendedor *',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ej: 1',
                helperText: 'ID del vendedor en SAP',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El código de vendedor es requerido';
                }
                if (int.tryParse(value) == null) {
                  return 'Debe ser un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: 'Comentarios',
                prefixIcon: const Icon(Icons.comment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Comentarios adicionales sobre la cotización...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _deliveryTimeController,
              decoration: InputDecoration(
                labelText: 'Tiempo de Entrega',
                prefixIcon: const Icon(Icons.schedule),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ej: 5-7 días hábiles',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _offerValidityController,
              decoration: InputDecoration(
                labelText: 'Validez de la Oferta',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ej: 30 días',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _paymentMethodController,
              decoration: InputDecoration(
                labelText: 'Forma de Pago',
                prefixIcon: const Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ej: Contado, Crédito 30 días',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      labelText: 'Latitud',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Ej: -16.5000',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      labelText: 'Longitud',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Ej: -68.1500',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'La ubicación se registrará automáticamente si no se especifica',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentLinesSection() {
    return Column(
      children: [
        if (_documentLines.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos agregados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar productos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_documentLines.length, (index) {
            return _buildLineItem(index);
          }),
      ],
    );
  }

  Widget _buildLineItem(int index) {
    final line = _documentLines[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Producto ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeLine(index),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              initialValue: line.itemCode,
              decoration: InputDecoration(
                labelText: 'Código del Producto *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Ej: A00001',
                helperText: 'Código del producto en SAP',
              ),
              onChanged: (value) => _onItemCodeChanged(index, value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El código del producto es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: line.quantity.toString(),
                    decoration: InputDecoration(
                      labelText: 'Cantidad *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 0.0;
                      setState(() {
                        _documentLines[index] = _documentLines[index].copyWith(quantity: quantity);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Cantidad inválida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: UomDropdown(
                    itemCode: line.itemCode,
                    selectedUom: line.selectedUom,
                    onChanged: (uom) => _onUomChanged(index, uom),
                    enabled: line.itemCode.isNotEmpty,
                    label: 'UoM',
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              initialValue: line.priceAfterVAT.toString(),
              decoration: InputDecoration(
                labelText: 'Precio con IVA *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: 'Bs. ',
                helperText: 'Precio unitario incluyendo IVA',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0.0;
                setState(() {
                  _documentLines[index] = _documentLines[index].copyWith(priceAfterVAT: price);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio es requerido';
                }
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Precio inválido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Línea:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Bs. ${NumberFormat('#,##0.00').format(line.quantity * line.priceAfterVAT)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Mostrar información de la UoM seleccionada
            if (line.selectedUom != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'UoM: ${line.selectedUom!.displayText} (${line.selectedUom!.baseQty}:${line.selectedUom!.altQty})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
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
    );
  }
}

