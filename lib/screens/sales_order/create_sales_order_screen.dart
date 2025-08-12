import 'package:appventas/blocs/payment_group/payment_group_bloc.dart';
import 'package:appventas/blocs/payment_group/payment_group_event.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_bloc.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_event.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_state.dart';
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/customer/customer_event.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/item/item_event.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:appventas/screens/items/item_selection_screen.dart';
import 'package:appventas/screens/payment_group/payment_group_selection_screen.dart';
import 'package:appventas/services/current_user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class CreateSalesOrderScreen extends StatefulWidget {
  const CreateSalesOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateSalesOrderScreen> createState() => _CreateSalesOrderScreenState();
}

class _CreateSalesOrderScreenState extends State<CreateSalesOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _salesPersonController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _warehouseController = TextEditingController();

  final _currentUserService = CurrentUserService();
  
  List<SalesOrderLineItem> _documentLines = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _hasLocationData = false;
  Customer? _selectedCustomer;
  PaymentGroup? _selectedPaymentGroup;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _salesPersonController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _warehouseController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    // Cargar datos del usuario actual
    if (_currentUserService.hasSalesPersonData) {
      _salesPersonController.text = _currentUserService.salesPersonFieldDisplay;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _hasLocationData = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación obtenida correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener ubicación: $e')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _selectPaymentGroup() async {
    try {
      // Trigger payment group search if needed
      context.read<PaymentGroupBloc>().add(PaymentGroupSearchRequested());
      final paymentGroup = await Navigator.push<PaymentGroup>(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentGroupSelectionScreen(),
        ),
      );
      if (paymentGroup != null) {
        setState(() {
          _selectedPaymentGroup = paymentGroup;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir selección de grupos de pago: $e')),);
    }
  }
  void _selectCustomer() async {
    try {
      // Trigger customer search if needed
      context.read<CustomerBloc>().add(CustomerSearchRequested());
      final customer = await Navigator.push<Customer>(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerSelectionScreen(),
        ),
      );
      if (customer != null) {
        setState(() {
          _selectedCustomer = customer;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir selección de clientes: $e')),);
    }
  }


  void _addItem() async {
    try {
      // Trigger item search if needed
      context.read<ItemBloc>().add(ItemSearchRequested());
      
      final item = await Navigator.push<Item>(
        context,
        MaterialPageRoute(
          builder: (context) => const ItemSelectionScreen(),
        ),
      );

      if (item != null) {
        setState(() {
          _documentLines.add(SalesOrderLineItem.fromItem(item));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir selección de items: $e')),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _documentLines.removeAt(index);
    });
  }

  void _updateItemQuantity(int index, double quantity) {
    if (quantity >= 0) {
      setState(() {
        _documentLines[index] = _documentLines[index].copyWith(quantity: quantity);
      });
    }
  }

  void _updateItemPrice(int index, double price) {
    if (price >= 0) {
      setState(() {
        _documentLines[index] = _documentLines[index].copyWith(priceAfterVAT: price);
      });
    }
  }

  void _updateItemDescription(int index, String description) {
    setState(() {
      _documentLines[index] = _documentLines[index].copyWith(uDescitemfacil: description);
    });
  }

  void _updateItemWarehouse(int index, String warehouse) {
    setState(() {
      _documentLines[index] = _documentLines[index].copyWith(warehouseCode: warehouse);
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_documentLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un item'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validar que todos los items tengan cantidad y precio válidos
    for (int i = 0; i < _documentLines.length; i++) {
      final item = _documentLines[i];
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El item ${item.itemCode} debe tener una cantidad mayor a 0'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (item.priceAfterVAT <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El item ${item.itemCode} debe tener un precio mayor a 0'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  void _createOrder() {
    if (!_validateForm()) {
      return;
    }

    final now = DateTime.now();
    
    final orderDto = SalesOrderDto(
      cardCode: _selectedCustomer!.cardCode,
      comments: _commentsController.text.trim(),
      salesPersonCode: _currentUserService.currentSalesPerson?.slpCode ?? 1,
      uUsrventafacil: _currentUserService.currentUser?.username ?? '',
      uLatitud: _latitudeController.text.trim().isNotEmpty ? _latitudeController.text.trim() : null,
      uLongitud: _longitudeController.text.trim().isNotEmpty ? _longitudeController.text.trim() : null,
      uFecharegistroapp: now,
      uHoraregistroapp: now,
      uLbRazonSocial: _selectedCustomer!.cardName,
      uLbNit: _selectedCustomer!.licTradNum.isNotEmpty ? _selectedCustomer!.licTradNum : null,
      uNit: _selectedCustomer!.licTradNum.isNotEmpty ? _selectedCustomer!.licTradNum : null,
      defaultWarehouseCode: _warehouseController.text.trim().isNotEmpty 
          ? _warehouseController.text.trim() 
          : null,
      documentLines: _documentLines.map((item) => SalesOrderLineDto(
        itemCode: item.itemCode,
        quantity: item.quantity,
        priceAfterVAT: item.priceAfterVAT,
        uomEntry: item.uomEntry ?? 1,
        uDescitemfacil: item.uDescitemfacil.isNotEmpty 
            ? item.uDescitemfacil 
            : item.itemName, // Usar el nombre del item como descripción por defecto
        warehouseCode: item.warehouseCode.isNotEmpty 
            ? item.warehouseCode 
            : _warehouseController.text.trim().isNotEmpty 
                ? _warehouseController.text.trim() 
                : null,
      )).toList(),
    );

    context.read<SalesOrdersBloc>().add(SalesOrderCreateRequested(orderDto));
  }

  void _showOrderPreview() {
    if (!_validateForm()) {
      return;
    }

    final totalAmount = _documentLines.fold(0.0, (sum, item) => sum + item.lineTotal);
    final numberFormat = NumberFormat.currency(symbol: 'Bs. ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Orden de Venta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cliente: ${_selectedCustomer!.cardName}'),
                Text('Vendedor: ${_salesPersonController.text}'),
                Text('Items: ${_documentLines.length}'),
                Text('Total: ${numberFormat.format(totalAmount)}'),
                const SizedBox(height: 8),
                Text('Comentarios: ${_commentsController.text}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createOrder();
              },
              child: const Text('Crear Orden'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Orden de Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _showOrderPreview,
            tooltip: 'Vista previa',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _createOrder,
            tooltip: 'Crear orden',
          ),
        ],
      ),
      body: BlocListener<SalesOrdersBloc, SalesOrdersState>(
        listener: (context, state) {
          if (state is SalesOrdersLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is SalesOrderCreated) {
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.result),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            // Retornar a la pantalla anterior
            Navigator.pop(context, true);
          }

          if (state is SalesOrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de progreso si está cargando
                if (_isLoading)
                  const LinearProgressIndicator(),
                
                const SizedBox(height: 8),
                
                // Sección Cliente
                _buildCustomerSection(),
                
                const SizedBox(height: 16),

                // Sección de Condición de Pago
                _buildPaymentGroupSection(),
                const SizedBox(height: 16),

                // Sección Vendedor
                _buildSalesPersonSection(),
                
                const SizedBox(height: 16),
                
                // Sección Ubicación
                _buildLocationSection(),
                
                const SizedBox(height: 16),
                
                // Sección Almacén por defecto
                _buildWarehouseSection(),
                
                const SizedBox(height: 16),
                
                // Sección Comentarios
                _buildCommentsSection(),
                
                const SizedBox(height: 24),
                
                // Sección Items
                _buildItemsSection(),
                
                const SizedBox(height: 24),
                
                // Botón Crear
                _buildCreateButton(),
                
                const SizedBox(height: 32), // Espacio extra al final
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Cliente *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedCustomer != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _selectedCustomer!.cardCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_selectedCustomer!.cardName),
                    if (_selectedCustomer!.licTradNum.isNotEmpty)
                      Text('NIT: ${_selectedCustomer!.licTradNum}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectCustomer,
                icon: const Icon(Icons.search),
                label: Text(_selectedCustomer == null ? 'Seleccionar Cliente' : 'Cambiar Cliente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCustomer == null ? null : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentGroupSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Condición de Pago *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedCustomer != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _selectedCustomer!.cardCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_selectedCustomer!.cardName),
                    if (_selectedCustomer!.licTradNum.isNotEmpty)
                      Text('NIT: ${_selectedCustomer!.licTradNum}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectCustomer,
                icon: const Icon(Icons.search),
                label: Text(_selectedCustomer == null ? 'Seleccionar Cliente' : 'Cambiar Cliente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCustomer == null ? null : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesPersonSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Vendedor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _salesPersonController,
              decoration: const InputDecoration(
                labelText: 'Vendedor Asignado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_pin),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Ubicación GPS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: (_isLoadingLocation || _isLoading) ? null : _getCurrentLocation,
                  icon: _isLoadingLocation 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: const Text('Obtener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasLocationData ? Colors.green : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            if (_hasLocationData) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 8),
                    const Text('Ubicación obtenida correctamente'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warehouse, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Almacén por Defecto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _warehouseController,
              decoration: const InputDecoration(
                labelText: 'Código de Almacén',
                hintText: 'Ej: 102-LP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
                helperText: 'Se aplicará a todos los items sin almacén específico',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.comment, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Comentarios *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Comentarios de la orden',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
                helperText: 'Describe el propósito de esta orden',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los comentarios son requeridos';
                }
                if (value.trim().length < 10) {
                  return 'Los comentarios deben tener al menos 10 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Items * (${_documentLines.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_documentLines.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No hay items agregados',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Agrega al menos un item para continuar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_documentLines.length, (index) {
                return _buildItemCard(index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _documentLines[index];
    final numberFormat = NumberFormat.currency(symbol: 'Bs. ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con código y botón eliminar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      item.itemName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _isLoading ? null : () => _removeItem(index),
                tooltip: 'Eliminar item',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Descripción editable
          TextFormField(
            initialValue: item.uDescitemfacil,
            decoration: const InputDecoration(
              labelText: 'Descripción personalizada',
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(Icons.edit),
            ),
            onChanged: (value) => _updateItemDescription(index, value),
            enabled: !_isLoading,
          ),
          
          const SizedBox(height: 12),
          
          // Cantidad y Precio
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad *',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final quantity = double.tryParse(value) ?? 0;
                    _updateItemQuantity(index, quantity);
                  },
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: item.priceAfterVAT.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0;
                    _updateItemPrice(index, price);
                  },
                  enabled: !_isLoading,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Almacén
          TextFormField(
            initialValue: item.warehouseCode,
            decoration: const InputDecoration(
              labelText: 'Almacén específico',
              hintText: 'Opcional - usa almacén por defecto',
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(Icons.warehouse),
            ),
            onChanged: (value) => _updateItemWarehouse(index, value),
            enabled: !_isLoading,
          ),
          
          const SizedBox(height: 12),
          
          // Total con validación visual
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.lineTotal > 0 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total línea:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: item.lineTotal > 0 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                Text(
                  numberFormat.format(item.lineTotal),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: item.lineTotal > 0 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    final totalAmount = _documentLines.fold(0.0, (sum, item) => sum + item.lineTotal);
    final numberFormat = NumberFormat.currency(symbol: 'Bs. ');
    final hasValidItems = _documentLines.isNotEmpty && 
        _documentLines.every((item) => item.quantity > 0 && item.priceAfterVAT > 0);

    return Column(
      children: [
        if (_documentLines.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasValidItems 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasValidItems 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.orange.shade300,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total General:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      numberFormat.format(totalAmount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasValidItems ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                if (!hasValidItems) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade600, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Verifica que todos los items tengan cantidad y precio válidos',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Botones de acción
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _showOrderPreview,
                icon: const Icon(Icons.preview),
                label: const Text('Vista Previa'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createOrder,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_cart),
                label: Text(_isLoading ? 'Creando...' : 'Crear Orden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasValidItems && _selectedCustomer != null 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Clase auxiliar para manejar los items en la orden
class SalesOrderLineItem {
  final String itemCode;
  final String itemName;
  final double quantity;
  final double priceAfterVAT;
  final int? uomEntry;
  final String warehouseCode;
  final String uDescitemfacil;

  SalesOrderLineItem({
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.priceAfterVAT,
    this.uomEntry,
    this.warehouseCode = '',
    required this.uDescitemfacil,
  });

  factory SalesOrderLineItem.fromItem(Item item) {
    return SalesOrderLineItem(
      itemCode: item.itemCode,
      itemName: item.itemName,
      quantity: 1.0,
      priceAfterVAT: 0.0, // Se debe configurar manualmente
      uomEntry: null, // Se puede obtener del UOM del item
      warehouseCode: '',
      uDescitemfacil: item.itemName, // Por defecto usa el nombre del item
    );
  }

  SalesOrderLineItem copyWith({
    String? itemCode,
    String? itemName,
    double? quantity,
    double? priceAfterVAT,
    int? uomEntry,
    String? warehouseCode,
    String? uDescitemfacil,
  }) {
    return SalesOrderLineItem(
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      priceAfterVAT: priceAfterVAT ?? this.priceAfterVAT,
      uomEntry: uomEntry ?? this.uomEntry,
      warehouseCode: warehouseCode ?? this.warehouseCode,
      uDescitemfacil: uDescitemfacil ?? this.uDescitemfacil,
    );
  }

  double get lineTotal => quantity * priceAfterVAT;
}