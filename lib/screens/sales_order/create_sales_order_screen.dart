// lib/screens/sales_order/create_sales_order_screen.dart
import 'package:appventas/blocs/payment_group/payment_group_bloc.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_bloc.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_event.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_state.dart';
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/tfe_oum/tfe_uom_bloc.dart';
import 'package:appventas/blocs/tfe_oum/tfe_uom_event.dart';
import 'package:appventas/blocs/uom/uom_bloc.dart';
import 'package:appventas/blocs/uom/uom_event.dart';
import 'package:appventas/blocs/user_series/user_series_bloc.dart';
import 'package:appventas/blocs/user_series/user_series_event.dart';
import 'package:appventas/blocs/user_series/user_series_state.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/models/item/tfe_unit_of_measure.dart';
import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:appventas/models/user_serie.dart';
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:appventas/screens/items/item_selection_screen.dart';
import 'package:appventas/screens/items/uom_selection_screen.dart';
import 'package:appventas/screens/items/tfe_uom_selection_screen.dart';
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
  bool _isLoadingPaymentGroup = false;
  bool _hasLocationData = false;
  Customer? _selectedCustomer;
  PaymentGroup? _selectedPaymentGroup;
  UserSerie? _selectedSeries;
  Warehouse? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
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

  void _initializeScreen() async {
    await _loadCurrentUserInfo();
    await _getLocation();
    final currentUser = await _currentUserService.loadCurrentUser();
    if (currentUser != null) {
      context.read<UserSeriesBloc>().add(UserSeriesLoadRequested(currentUser.id));
    }
    context.read<TfeUomBloc>().add(TfeUomLoadRequested());
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      final currentUser = await _currentUserService.loadCurrentUser();
      if (currentUser != null) {
        setState(() {
          _salesPersonController.text = _currentUserService.salesPersonFieldDisplay;
          _warehouseController.text = currentUser.almacenCode ?? '';
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permisos de ubicación denegados';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Permisos de ubicación denegados permanentemente';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _hasLocationData = true;
      });
    } catch (e) {
      print('Error obtaining location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la ubicación: $e')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCustomer!.cardName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${_selectedCustomer!.cardCode}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _selectCustomer,
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar Cliente'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectCustomer,
                  icon: const Icon(Icons.search),
                  label: const Text('Seleccionar Cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_list_numbered, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Serie *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<UserSeriesBloc, UserSeriesState>(
              builder: (context, state) {
                if (state is UserSeriesLoading) {
                  return const LinearProgressIndicator();
                }
                
                if (state is UserSeriesLoaded) {
                  return DropdownButtonFormField<UserSerie>(
                    value: _selectedSeries,
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Serie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: state.userSeries.map((serie) {
                      return DropdownMenuItem<UserSerie>(
                        value: serie,
                        child: Text('${serie.seriesName} - ${serie.nextNumber}'),
                      );
                    }).toList(),
                    onChanged: (UserSerie? newSerie) {
                      setState(() {
                        _selectedSeries = newSerie;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor seleccione una serie';
                      }
                      return null;
                    },
                  );
                }
                
                if (state is UserSeriesError) {
                  return Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  );
                }
                
                return const Text('No hay series disponibles');
              },
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
            if (_selectedPaymentGroup != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPaymentGroup!.pymntGroup,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${_selectedPaymentGroup!.groupNum}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _selectPaymentGroup,
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar Condición'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedCustomer != null ? _selectPaymentGroup : null,
                  icon: _isLoadingPaymentGroup
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoadingPaymentGroup ? 'Cargando...' : 'Seleccionar Condición'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCustomer != null 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_selectedCustomer == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Primero debe seleccionar un cliente',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
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
                Icon(Icons.person_pin, color: Theme.of(context).primaryColor),
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
              decoration: InputDecoration(
                labelText: 'Nombre del Vendedor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
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
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Ubicación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoadingLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_hasLocationData)
                  Icon(Icons.check_circle, color: Colors.green[600])
                else
                  TextButton.icon(
                    onPressed: _getLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Obtener'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
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
              decoration: InputDecoration(
                labelText: 'Código de Almacén',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.store),
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
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: 'Comentarios adicionales',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
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
              children: [
                Icon(Icons.inventory, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_documentLines.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay items agregados',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presione "Agregar Item" para comenzar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _documentLines.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _documentLines[index];
                  return _buildItemCard(item, index);
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ').format(_calculateTotal()),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
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

  Widget _buildItemCard(SalesOrderLineItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
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
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${item.itemCode}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Eliminar item',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final quantity = double.tryParse(value) ?? 1.0;
                    _updateItemQuantity(index, quantity);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.priceAfterVAT.toString(),
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    _updateItemPrice(index, price);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unidad de Medida',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _selectUnitOfMeasure(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue[50],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.selectedUom?.displayShort ?? 'Seleccionar',
                                style: TextStyle(
                                  color: item.selectedUom != null ? Colors.blue[700] : Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: item.selectedUom != null ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UM de Venta',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _selectTfeUnitOfMeasure(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.orange[50],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.point_of_sale,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.selectedTfeUom?.displayShort ?? 'Seleccionar',
                                style: TextStyle(
                                  color: item.selectedTfeUom != null ? Colors.orange[700] : Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: item.selectedTfeUom != null ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.orange[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Subtotal: ${NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ').format(item.lineTotal)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,),
             ),
           ],
         ),
       ],
     ),
   );
 }

 Widget _buildCreateButton() {
   final canCreate = _selectedCustomer != null && 
                    _selectedSeries != null && 
                    _selectedPaymentGroup != null && 
                    _documentLines.isNotEmpty &&
                    _documentLines.every((item) => item.selectedUom != null && item.selectedTfeUom != null);

   return SizedBox(
     width: double.infinity,
     child: ElevatedButton.icon(
       onPressed: canCreate && !_isLoading ? _createSalesOrder : null,
       icon: _isLoading
           ? const SizedBox(
               width: 20,
               height: 20,
               child: CircularProgressIndicator(
                 strokeWidth: 2,
                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
               ),
             )
           : const Icon(Icons.save),
       label: Text(_isLoading ? 'Creando Orden...' : 'Crear Orden de Venta'),
       style: ElevatedButton.styleFrom(
         backgroundColor: canCreate 
             ? Theme.of(context).primaryColor 
             : Colors.grey,
         foregroundColor: Colors.white,
         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
         padding: const EdgeInsets.symmetric(vertical: 16),
       ),
     ),
   );
 }

 Future<void> _selectCustomer() async {
   final selectedCustomer = await Navigator.of(context).push<Customer>(
     MaterialPageRoute(
       builder: (context) => BlocProvider.value(
         value: context.read<CustomerBloc>(),
         child: const CustomerSelectionScreen(),
       ),
     ),
   );

   if (selectedCustomer != null) {
     setState(() {
       _selectedCustomer = selectedCustomer;
       _selectedPaymentGroup = null;
     });
   }
 }

 Future<void> _selectPaymentGroup() async {
   if (_selectedCustomer == null) return;

   setState(() {
     _isLoadingPaymentGroup = true;
   });

   try {
     final selectedPaymentGroup = await Navigator.of(context).push<PaymentGroup>(
       MaterialPageRoute(
         builder: (context) => BlocProvider.value(
           value: context.read<PaymentGroupBloc>(),
           child: PaymentGroupSelectionScreen(
             initialPaymentGroup: _selectedPaymentGroup,
           ),
         ),
       ),
     );

     if (selectedPaymentGroup != null) {
       setState(() {
         _selectedPaymentGroup = selectedPaymentGroup;
       });
     }
   } catch (e) {
     print('Error selecting payment group: $e');
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error al seleccionar condición de pago: $e')),
     );
   } finally {
     setState(() {
       _isLoadingPaymentGroup = false;
     });
   }
 }

 Future<void> _addItem() async {
   final selectedItem = await Navigator.of(context).push<Item>(
     MaterialPageRoute(
       builder: (context) => BlocProvider.value(
         value: context.read<ItemBloc>(),
         child: const ItemSelectionScreen(),
       ),
     ),
   );

   if (selectedItem != null) {
     final newLineItem = SalesOrderLineItem.fromItem(selectedItem);
     setState(() {
       _documentLines.add(newLineItem);
     });

     context.read<UomBloc>().add(UomLoadRequested(selectedItem.itemCode));
   }
 }

 Future<void> _selectUnitOfMeasure(int index) async {
   final item = _documentLines[index];
   
   final selectedUom = await Navigator.of(context).push<UnitOfMeasure>(
     MaterialPageRoute(
       builder: (context) => BlocProvider.value(
         value: context.read<UomBloc>(),
         child: UomSelectionScreen(
           itemCode: item.itemCode,
           itemName: item.itemName,
           initialUom: item.selectedUom,
         ),
       ),
     ),
   );

   if (selectedUom != null) {
     setState(() {
       _documentLines[index] = _documentLines[index].copyWith(
         selectedUom: selectedUom,
         uomEntry: selectedUom.uomEntry,
       );
     });
   }
 }

 Future<void> _selectTfeUnitOfMeasure(int index) async {
   final item = _documentLines[index];
   
   final selectedTfeUom = await Navigator.of(context).push<TfeUnitOfMeasure>(
     MaterialPageRoute(
       builder: (context) => BlocProvider.value(
         value: context.read<TfeUomBloc>(),
         child: TfeUomSelectionScreen(
           initialTfeUom: item.selectedTfeUom,
         ),
       ),
     ),
   );

   if (selectedTfeUom != null) {
     setState(() {
       _documentLines[index] = _documentLines[index].copyWith(
         selectedTfeUom: selectedTfeUom,
       );
     });
   }
 }

 void _removeItem(int index) {
   setState(() {
     _documentLines.removeAt(index);
   });
 }

 void _updateItemQuantity(int index, double quantity) {
   setState(() {
     _documentLines[index] = _documentLines[index].copyWith(quantity: quantity);
   });
 }

 void _updateItemPrice(int index, double price) {
   setState(() {
     _documentLines[index] = _documentLines[index].copyWith(priceAfterVAT: price);
   });
 }

 Future<void> _createSalesOrder() async {
   if (!_formKey.currentState!.validate()) {
     return;
   }

   if (_selectedCustomer == null) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Debe seleccionar un cliente')),
     );
     return;
   }

   if (_selectedSeries == null) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Debe seleccionar una serie')),
     );
     return;
   }

   if (_selectedPaymentGroup == null) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Debe seleccionar una condición de pago')),
     );
     return;
   }

   if (_documentLines.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Debe agregar al menos un item')),
     );
     return;
   }

   final itemsWithoutUom = _documentLines.where((item) => item.selectedUom == null).toList();
   if (itemsWithoutUom.isNotEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Todos los items deben tener una unidad de medida seleccionada')),
     );
     return;
   }

   final itemsWithoutTfeUom = _documentLines.where((item) => item.selectedTfeUom == null).toList();
   if (itemsWithoutTfeUom.isNotEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Todos los items deben tener una unidad de medida de venta seleccionada')),
     );
     return;
   }

   try {
     setState(() {
       _isLoading = true;
     });

     final currentUser = await _currentUserService.loadCurrentUser();
     if (currentUser == null) {
       throw Exception('No se pudo cargar la información del usuario');
     }
     
     final salesPersonName = _currentUserService.salesPersonName.isNotEmpty 
         ? _currentUserService.salesPersonName 
         : _salesPersonController.text;

     final documentLines = _documentLines.map((item) {
       return SalesOrderLineDto(
         itemCode: item.itemCode,
         quantity: item.quantity,
         priceAfterVAT: item.priceAfterVAT,
         uomEntry: item.selectedUom!.uomEntry,
         warehouseCode: item.warehouseCode.isNotEmpty 
             ? item.warehouseCode 
             : _warehouseController.text.trim().isNotEmpty 
                 ? _warehouseController.text.trim() 
                 : _currentUserService.currentUser?.almacenCode,
         uDescitemfacil: item.uDescitemfacil,
         uTfeCodeUMfact: item.selectedTfeUom!.code,
         uTfeNomUMfact: item.selectedTfeUom!.name,
       );
     }).toList();

     final salesOrderDto = SalesOrderDto(
       cardCode: _selectedCustomer!.cardCode,
       comments: _commentsController.text,
       salesPersonCode: _currentUserService.currentUser?.employeeCodeSap ?? 0,
       series: _selectedSeries!.idSerie != null ? int.tryParse(_selectedSeries!.idSerie) : null,
       paymentGroupCode: _selectedPaymentGroup!.groupNum,
       uUsrventafacil: salesPersonName,
       uLatitud: _latitudeController.text.isNotEmpty ? _latitudeController.text : null,
       uLongitud: _longitudeController.text.isNotEmpty ? _longitudeController.text : null,
       uFecharegistroapp: DateTime.now(),
       uHoraregistroapp: DateTime.now(),
       defaultWarehouseCode: _warehouseController.text.trim().isNotEmpty 
           ? _warehouseController.text.trim() 
           : _currentUserService.currentUser?.almacenCode,
       defaultTaxCode: 'IVA',
       documentLines: documentLines,
     );

     context.read<SalesOrdersBloc>().add(SalesOrderCreateRequested(salesOrderDto));
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error al crear orden: $e')),
     );
     setState(() {
       _isLoading = false;
     });
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Crear Orden de Venta'),
       backgroundColor: Theme.of(context).primaryColor,
       foregroundColor: Colors.white,
     ),
     body: MultiBlocListener(
       listeners: [
         BlocListener<SalesOrdersBloc, SalesOrdersState>(
           listener: (context, state) {
             if (state is SalesOrdersLoading) {
               setState(() {
                 _isLoading = true;
               });
             } else if (state is SalesOrderCreated) {
               setState(() {
                 _isLoading = false;
               });
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Orden creada exitosamente')),
               );
               Navigator.of(context).pop(true);
             } else if (state is SalesOrdersError) {
               setState(() {
                 _isLoading = false;
               });
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Error: ${state.message}')),
               );
             }
           },
         ),
         BlocListener<UserSeriesBloc, UserSeriesState>(
           listener: (context, state) {
             if (state is UserSeriesLoaded) {
               if (state.userSeries.isNotEmpty) {
                 setState(() {
                   _selectedSeries = state.userSeries.first;
                 });
               }
             }
           },
         ),
       ],
       child: Form(
         key: _formKey,
         child: SingleChildScrollView(
           padding: const EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               _buildCustomerSection(),
               const SizedBox(height: 16),
               _buildSeriesSection(),
               const SizedBox(height: 16),
               _buildPaymentGroupSection(),
               const SizedBox(height: 16),
               _buildSalesPersonSection(),
               const SizedBox(height: 16),
               _buildLocationSection(),
               const SizedBox(height: 16),
               _buildWarehouseSection(),
               const SizedBox(height: 16),
               _buildCommentsSection(),
               const SizedBox(height: 24),
               _buildItemsSection(),
               const SizedBox(height: 24),
               _buildCreateButton(),
               const SizedBox(height: 32),
             ],
           ),
         ),
       ),
     ),
   );
 }

 double _calculateTotal() {
   return _documentLines.fold(
     0.0,
     (total, item) => total + (item.quantity * item.priceAfterVAT),
   );
 }
}

class SalesOrderLineItem {
 final String itemCode;
 final String itemName;
 final double quantity;
 final double priceAfterVAT;
 final int? uomEntry;
 final String warehouseCode;
 final String uDescitemfacil;
 final UnitOfMeasure? selectedUom;
 final TfeUnitOfMeasure? selectedTfeUom;

 SalesOrderLineItem({
   required this.itemCode,
   required this.itemName,
   required this.quantity,
   required this.priceAfterVAT,
   this.uomEntry,
   this.warehouseCode = '',
   required this.uDescitemfacil,
   this.selectedUom,
   this.selectedTfeUom,
 });

 factory SalesOrderLineItem.fromItem(Item item) {
   return SalesOrderLineItem(
     itemCode: item.itemCode,
     itemName: item.itemName,
     quantity: 1.0,
     priceAfterVAT: 0.0,
     uomEntry: null,
     warehouseCode: '',
     uDescitemfacil: item.itemName,
     selectedUom: null,
     selectedTfeUom: null,
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
   UnitOfMeasure? selectedUom,
   TfeUnitOfMeasure? selectedTfeUom,
 }) {
   return SalesOrderLineItem(
     itemCode: itemCode ?? this.itemCode,
     itemName: itemName ?? this.itemName,
     quantity: quantity ?? this.quantity,
     priceAfterVAT: priceAfterVAT ?? this.priceAfterVAT,
     uomEntry: uomEntry ?? this.uomEntry,
     warehouseCode: warehouseCode ?? this.warehouseCode,
     uDescitemfacil: uDescitemfacil ?? this.uDescitemfacil,
     selectedUom: selectedUom ?? this.selectedUom,
     selectedTfeUom: selectedTfeUom ?? this.selectedTfeUom,
   );
 }

 double get lineTotal => quantity * priceAfterVAT;
}