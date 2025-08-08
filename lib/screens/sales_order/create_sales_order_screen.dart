
// lib/screens/sales_order/create_sales_order_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:appventas/blocs/sales_order/sales_order_bloc.dart';
import 'package:appventas/blocs/sales_order/sales_order_event.dart';
import 'package:appventas/blocs/sales_order/sales_order_state.dart';
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/uom/uom_bloc.dart';
import 'package:appventas/blocs/uom/uom_event.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/models/sales_order/sales_order_line_dto.dart';
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:appventas/screens/items/item_selection_screen.dart';
import 'package:appventas/services/current_user_service.dart';

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
  final _razonesSocialesController = TextEditingController();
  final _nitController = TextEditingController();

  final _currentUserService = CurrentUserService();
  
  List<SalesOrderLineItem> _documentLines = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _hasLocationData = false;
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  int _selectedSeries = 13; // Serie por defecto
  int _selectedPaymentGroup = 1; // Grupo de pago por defecto

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    await _currentUserService.loadCurrentUser();
    if (_currentUserService.hasSalesPersonData) {
      _salesPersonController.text = _currentUserService.salesPersonFieldDisplay;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Orden de Venta'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SalesOrderBloc, SalesOrderState>(
        listener: (context, state) {
          if (state is SalesOrderLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is SalesOrderCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${state.response.message}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          }

          if (state is SalesOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCustomerSection(),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildSalesPersonSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildCustomerDataSection(),
            const SizedBox(height: 16),
            _buildItemsSection(),
            const SizedBox(height: 16),
            _buildCommentsSection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(_selectedCustomer?.cardName ?? 'Seleccionar cliente'),
              subtitle: _selectedCustomer != null
                  ? Text('Código: ${_selectedCustomer!.cardCode}')
                  : const Text('Toque para seleccionar un cliente'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectCustomer,
              tileColor: _selectedCustomer == null ? Colors.orange[50] : Colors.green[50],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fechas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha del Documento'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    onTap: () => _selectDate(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Fecha de Vencimiento'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDueDate)),
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesPersonSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendedor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _salesPersonController,
              decoration: const InputDecoration(
                labelText: 'Vendedor asignado',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe tener un vendedor asignado';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ubicación GPS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on),
                  label: Text(_isLoadingLocation ? 'Obteniendo...' : 'Obtener Ubicación'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            if (!_hasLocationData)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recomendado: Obtener ubicación GPS',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Adicionales del Cliente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _razonesSocialesController,
              decoration: const InputDecoration(
                labelText: 'Razón Social',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La razón social es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nitController,
              decoration: const InputDecoration(
                labelText: 'NIT',
                prefixIcon: Icon(Icons.assignment_ind),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El NIT es requerido';
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos (${_documentLines.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Producto'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_documentLines.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay productos agregados.\nToque "Agregar Producto" para comenzar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._documentLines.asMap().entries.map((entry) {
                final index = entry.key;
                final line = entry.value;
                return _buildItemCard(line, index);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(SalesOrderLineItem line, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.itemCode,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        line.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Cantidad: ${line.quantity}'),
                ),
                Expanded(
                  child: Text('Precio: Bs. ${line.priceAfterVAT.toStringAsFixed(2)}'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text('UoM: ${line.uomName}'),
                ),
                Expanded(
                  child: Text('Total: Bs. ${(line.quantity * line.priceAfterVAT).toStringAsFixed(2)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comentarios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Comentarios adicionales',
                hintText: 'Escriba comentarios sobre la orden de venta...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedCustomer != null && 
                     _documentLines.isNotEmpty && 
                     _currentUserService.hasSalesPersonData &&
                     _razonesSocialesController.text.isNotEmpty &&
                     _nitController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: canSubmit && !_isLoading ? _submitOrder : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Creando Orden...'),
              ],
            )
          : const Text(
              'Crear Orden de Venta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  // ==================== MÉTODOS DE FUNCIONALIDAD ====================

  void _selectCustomer() async {
    final customer = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CustomerBloc>()),
          ],
          child: const CustomerSelectionScreen(),
        ),
      ),
    );

    if (customer != null) {
      setState(() {
        _selectedCustomer = customer;
        // Pre-llenar datos del cliente si están disponibles
        if (customer.cardName.isNotEmpty) {
          _razonesSocialesController.text = customer.cardName;
        }
        if (customer.licTradNum?.isNotEmpty == true) {
          _nitController.text = customer.licTradNum!;
        }
      });
    }
  }

  void _selectDate(bool isDocDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isDocDate ? _selectedDate : _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isDocDate) {
          _selectedDate = date;
          // Ajustar fecha de vencimiento si es necesario
          if (_selectedDueDate.isBefore(date)) {
            _selectedDueDate = date.add(const Duration(days: 30));
          }
        } else {
          _selectedDueDate = date;
        }
      });
    }
  }

  void _getCurrentLocation() async {
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
        const SnackBar(
          content: Text('✅ Ubicación obtenida correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al obtener ubicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _addItem() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ItemBloc>()),
            BlocProvider.value(value: context.read<UomBloc>()),
          ],
          child: const ItemSelectionScreen(),
        ),
      ),
    );

    if (result != null) {
      final item = result['item'] as Item;
      final quantity = result['quantity'] as double;
      final unitOfMeasure = result['unitOfMeasure'] as UnitOfMeasure;
      final price = result['price'] as double;

      final lineItem = SalesOrderLineItem(
        itemCode: item.itemCode,
        description: item.itemName,
        quantity: quantity,
        priceAfterVAT: price,
        uomEntry: unitOfMeasure.uomEntry,
        uomName: unitOfMeasure.uomName,
        warehouseCode: _currentUserService.currentUser?.almacenCode ?? '102-LP',
        taxCode: 'IVA',
        discountPercent: 0.0,
        shipDate: _selectedDueDate,
      );

      setState(() {
        _documentLines.add(lineItem);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _documentLines.removeAt(index);
    });
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Debe seleccionar un cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_documentLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Debe agregar al menos un producto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final currentUser = _currentUserService.currentUser;
    final salesPerson = _currentUserService.currentSalesPerson;

    if (currentUser == null || salesPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error: No se encontraron datos del usuario o vendedor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final salesOrderDto = SalesOrderDto(
      docEntry: null,
      docDate: _selectedDate,
      docDueDate: _selectedDueDate,
      cardCode: _selectedCustomer!.cardCode,
      comments: '${currentUser.username} : Creado por app mobile ${DateFormat('dd-MM-yyyy').format(now)}${_commentsController.text.isNotEmpty ? '\n${_commentsController.text}' : ''}',
      series: _selectedSeries,
      salesPersonCode: salesPerson.slpCode,
      contactPersonCode: null,
      paymentGroupCode: _selectedPaymentGroup,
      documentLines: _documentLines.map((line) => SalesOrderLineDto(
        itemCode: line.itemCode,
        quantity: line.quantity,
        taxCode: line.taxCode,
        priceAfterVAT: line.priceAfterVAT,
        discountPercent: line.discountPercent,
        uoMEntry: line.uomEntry,
        shipDate: line.shipDate,
        warehouseCode: line.warehouseCode,
        uDescitemfacil: line.description,
        uPrecioVenta: line.priceAfterVAT,
        uPrecioItemVenta: line.priceAfterVAT,
        uTfeCodeUMfact: line.uomEntry.toString(),
        uTfeNomUMfact: line.uomName,
      )).toList(),
      uUsrventafacil: currentUser.username,
      uLatitud: _latitudeController.text.isNotEmpty ? _latitudeController.text : null,
      uLongitud: _longitudeController.text.isNotEmpty ? _longitudeController.text : null,
      uFecharegistroapp: now,
      uHoraregistroapp: now,
      cardForeignName: null,
      uCodigocliente: null,
      uLbRazonSocial: _razonesSocialesController.text,
      uNit: _nitController.text,
      uLbNit: _nitController.text,
    );

    context.read<SalesOrderBloc>().add(SalesOrderCreateRequested(salesOrderDto));
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _salesPersonController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _razonesSocialesController.dispose();
    _nitController.dispose();
    super.dispose();
  }
}


/// Clase auxiliar para manejar items en la lista durante la creación
class SalesOrderLineItem {
  final String itemCode;
  final String description;
  final double quantity;
  final double priceAfterVAT;
  final int uomEntry;
  final String uomName;
  final String warehouseCode;
  final String taxCode;
  final double discountPercent;
  final DateTime shipDate;

  SalesOrderLineItem({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.priceAfterVAT,
    required this.uomEntry,
    required this.uomName,
    required this.warehouseCode,
    required this.taxCode,
    required this.discountPercent,
    required this.shipDate,
  });
}