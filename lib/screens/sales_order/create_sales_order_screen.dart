import 'package:appventas/blocs/payment_group/payment_group_bloc.dart';
import 'package:appventas/blocs/payment_group/payment_group_event.dart';
import 'package:appventas/blocs/payment_group/payment_group_state.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_bloc.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_event.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_state.dart';
import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/customer/customer_event.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/item/item_event.dart';
import 'package:appventas/blocs/user_series/user_series_bloc.dart';
import 'package:appventas/blocs/user_series/user_series_event.dart';
import 'package:appventas/blocs/user_series/user_series_state.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:appventas/models/user_serie.dart';
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:appventas/screens/items/item_selection_screen.dart';
import 'package:appventas/screens/payment_group/payment_group_selection_screen.dart';
import 'package:appventas/services/current_user_service.dart';
import 'package:appventas/widgets/warehouse_selector_widget.dart';
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
    _initializeForm();
  }

  void _initializeForm() async {
    try {
      // Cargar usuario actual si no está cargado
      await _currentUserService.loadCurrentUser();
      
      // Configurar el campo de vendedor según la configuración del usuario
      setState(() {
        if (_currentUserService.hasSalesPersonData) {
          // Si tiene datos completos del vendedor de SAP, mostrar el displayName
          _salesPersonController.text = _currentUserService.salesPersonFieldDisplay;
        } else if (_currentUserService.hasSapConfiguration) {
          // Si solo tiene configuración SAP, mostrar el código de empleado
          _salesPersonController.text = 'Código: ${_currentUserService.employeeCodeDisplay}';
        } else {
          // Si no tiene configuración SAP, dejar que ingrese manualmente
          _salesPersonController.text = '';
        }
      });

      // Cargar series del usuario usando el bloc
      await _loadUserSeries();
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _loadUserSeries() async {
    if (_currentUserService.currentUser == null) return;

    // Disparar evento para cargar series del usuario usando el bloc
    context.read<UserSeriesBloc>().add(
      UserSeriesLoadRequested(_currentUserService.currentUser!.id)
    );
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
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un cliente primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Trigger payment group search if needed
      context.read<PaymentGroupBloc>().add(PaymentGroupSearchRequested());
      final paymentGroup = await Navigator.push<PaymentGroup>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentGroupSelectionScreen(
            initialPaymentGroup: _selectedPaymentGroup,
          ),
        ),
      );
      if (paymentGroup != null) {
        setState(() {
          _selectedPaymentGroup = paymentGroup;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir selección de grupos de pago: $e')),
      );
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
          _selectedPaymentGroup = null; // Reset payment group
        });
        
        // Auto-cargar el payment group del customer si tiene uno asignado
        await _loadCustomerPaymentGroup(customer);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir selección de clientes: $e')),
      );
    }
  }

  Future<void> _loadCustomerPaymentGroup(Customer customer) async {
    if (customer.groupNum > 0) {
      setState(() {
        _isLoadingPaymentGroup = true;
      });

      try {
        // Cargar el payment group usando el groupNum del customer
        context.read<PaymentGroupBloc>().add(
          PaymentGroupByGroupNumRequested(customer.groupNum)
        );
      } catch (e) {
        print('Error al cargar payment group del customer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar condición de pago del cliente: $e')),
        );
      } finally {
        setState(() {
          _isLoadingPaymentGroup = false;
        });
      }
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
        SnackBar(content: Text('Error al abrir selección de artículos: $e')),
      );
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

  void _createSalesOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un cliente')),
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
        const SnackBar(content: Text('Debe agregar al menos un artículo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar que tengamos el usuario actual cargado
      if (_currentUserService.currentUser == null) {
        await _currentUserService.loadCurrentUser();
      }
      
      final currentUser = _currentUserService.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Determinar el salesPersonCode basado en la configuración del usuario
      int salesPersonCode;
      if (_currentUserService.hasSalesPersonData) {
        // Usar el slpCode del vendedor SAP
        salesPersonCode = _currentUserService.currentSalesPerson!.slpCode;
      } else if (_currentUserService.hasSapConfiguration) {
        // Usar el employeeCodeSap del usuario
        salesPersonCode = currentUser.employeeCodeSap!;
      } else {
        throw Exception('Usuario sin configuración de vendedor SAP válida');
      }

      // Determinar el nombre del usuario para uUsrventafacil
      String salesPersonName;
      if (_currentUserService.hasSalesPersonData) {
        salesPersonName = _currentUserService.salesPersonName;
      } else {
        salesPersonName = currentUser.name;
      }

      // Convertir SalesOrderLineItem a SalesOrderLineDto
      final documentLines = _documentLines.map((item) => SalesOrderLineDto(
        itemCode: item.itemCode,
        quantity: item.quantity,
        priceAfterVAT: item.priceAfterVAT,
        uomEntry: item.uomEntry ?? 1,
        taxCode: 'IVA',
        discountPercent: 0.0,
        warehouseCode: item.warehouseCode.isNotEmpty 
            ? item.warehouseCode 
            : _warehouseController.text.trim().isNotEmpty 
                ? _warehouseController.text.trim() 
                : null,
        uDescitemfacil: item.uDescitemfacil.isNotEmpty 
            ? item.uDescitemfacil 
            : item.itemName,
        uTfeCodeUMfact: '80',
        uTfeNomUMfact: 'FRA',
      )).toList();

      final salesOrderDto = SalesOrderDto(
        cardCode: _selectedCustomer!.cardCode,
        comments: _commentsController.text,
        salesPersonCode: salesPersonCode,
        series: _selectedSeries?.idSerie != null ? int.tryParse(_selectedSeries!.idSerie) : null,
        paymentGroupCode: _selectedPaymentGroup!.groupNum,
        uUsrventafacil: salesPersonName,
        uLatitud: _latitudeController.text.isNotEmpty ? _latitudeController.text : null,
        uLongitud: _longitudeController.text.isNotEmpty ? _longitudeController.text : null,
        uFecharegistroapp: DateTime.now(),
        uHoraregistroapp: DateTime.now(),
        defaultWarehouseCode: _warehouseController.text.trim().isNotEmpty 
            ? _warehouseController.text.trim() 
            : currentUser.almacenCode, // Usar almacén del usuario como fallback
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
                setState(() {
                  _selectedSeries = state.selectedSerie;
                });
              } else if (state is UserSeriesEmpty) {
                setState(() {
                  _selectedSeries = null;
                });
              } else if (state is UserSeriesError) {
                setState(() {
                  _selectedSeries = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cargar series: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<PaymentGroupBloc, PaymentGroupState>(
            listener: (context, state) {
              if (state is PaymentGroupDetailLoaded) {
                setState(() {
                  _selectedPaymentGroup = state.paymentGroup;
                  _isLoadingPaymentGroup = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Condición de pago cargada: ${state.paymentGroup.pymntGroup}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is PaymentGroupError) {
                setState(() {
                  _isLoadingPaymentGroup = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cargar condición de pago: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                // Sección Cliente
                _buildCustomerSection(),
                
                const SizedBox(height: 16),

                // Sección de Series
                _buildSeriesSection(),
                
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
                  'Serie de Numeración',
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
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cargando series asignadas...',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is UserSeriesEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No tienes series asignadas. Se usará la serie por defecto.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is UserSeriesError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is UserSeriesLoaded) {
                  // Encontrar la serie seleccionada actual en la lista del estado
                  UserSerie? currentSelectedSerie;
                  final selectedSeriesId = _selectedSeries?.id;
                  
                  if (selectedSeriesId != null) {
                    try {
                      currentSelectedSerie = state.userSeries.firstWhere(
                        (serie) => serie.id == selectedSeriesId,
                      );
                    } catch (e) {
                      // Si no se encuentra, usar la primera serie o la seleccionada del estado
                      currentSelectedSerie = state.selectedSerie ?? 
                          (state.userSeries.isNotEmpty ? state.userSeries.first : null);
                    }
                  } else {
                    currentSelectedSerie = state.selectedSerie ?? 
                        (state.userSeries.isNotEmpty ? state.userSeries.first : null);
                  }

                  return DropdownButtonFormField<UserSerie>(
                    value: currentSelectedSerie,
                    decoration: InputDecoration(
                      labelText: 'Serie Asignada',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.format_list_numbered)
                    ),
                    items: state.userSeries.map((series) {
                      return DropdownMenuItem<UserSerie>(
                        value: series,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                series.displayName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (series.nextDocumentNumber.isNotEmpty)
                                Text(
                                  'Próximo: ${series.nextDocumentNumber}',
                                  style: TextStyle(
                                    fontSize: 5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (UserSerie? newValue) {
                      if (newValue != null) {
                        context.read<UserSeriesBloc>().add(UserSeriesSelected(newValue));
                        setState(() {
                          _selectedSeries = newValue;
                        });
                      }
                    },
                    hint: const Text('Seleccionar Serie'),
                    isExpanded: true, // Para manejar mejor el overflow
                  );
                }
                
                // Estado inicial o cualquier otro estado
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Cargando configuración de series...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentGroupSection() {
    final bool isDisabled = _selectedCustomer == null;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment, 
                  color: isDisabled ? Colors.grey : Theme.of(context).primaryColor
                ),
                const SizedBox(width: 8),
                Text(
                  'Condición de Pago *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : null,
                  ),
                ),
                if (_isLoadingPaymentGroup) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            
            // Mensaje informativo si no hay customer seleccionado
            if (isDisabled) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selecciona un cliente primero para habilitar las condiciones de pago',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Mostrar información del payment group seleccionado
            if (_selectedPaymentGroup != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.blue.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Grupo ${_selectedPaymentGroup!.groupNum}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_selectedCustomer != null && _selectedCustomer!.groupNum == _selectedPaymentGroup!.groupNum) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              'Por defecto',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_selectedPaymentGroup!.pymntGroup),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Botón para seleccionar/cambiar payment group
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isLoading || _isLoadingPaymentGroup || isDisabled) ? null : _selectPaymentGroup,
                icon: Icon(
                  Icons.search,
                  color: isDisabled ? Colors.grey : null,
                ),
                label: Text(_selectedPaymentGroup == null ? 'Seleccionar Condición de Pago' : 'Cambiar Condición de Pago'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled 
                      ? Colors.grey.shade300 
                      : _selectedPaymentGroup == null 
                          ? null 
                          : Colors.orange,
                  foregroundColor: isDisabled ? Colors.grey.shade600 : null,
                ),
              ),
            ),
            
            // Mensaje informativo si el customer tiene payment group
            if (_selectedCustomer != null && _selectedCustomer!.groupNum > 0 && _selectedPaymentGroup == null && !_isLoadingPaymentGroup) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Este cliente tiene una condición de pago por defecto (${_selectedCustomer!.pymntGroup})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
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
                Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Vendedor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentUserService.hasSapConfiguration) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.verified_user, color: Colors.green, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _salesPersonController,
              decoration: InputDecoration(
                labelText: _currentUserService.hasSalesPersonData
                    ? 'Vendedor SAP'
                    : _currentUserService.hasSapConfiguration
                        ? 'Código de Empleado SAP'
                        : 'Código de Vendedor',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge),
                hintText: _currentUserService.hasSapConfiguration
                    ? 'Obtenido automáticamente'
                    : 'Ingrese código de vendedor',
                helperText: _currentUserService.hasSalesPersonData
                    ? 'Datos obtenidos desde SAP'
                    : _currentUserService.hasSapConfiguration
                        ? 'Configuración automática del usuario'
                        : 'Código del vendedor en SAP',
                suffixIcon: _currentUserService.hasSapConfiguration
                    ? Icon(Icons.verified_user, color: Colors.green)
                    : null,
              ),
              readOnly: _currentUserService.hasSapConfiguration,
              keyboardType: _currentUserService.hasSalesPersonData 
                  ? TextInputType.text 
                  : TextInputType.number,
              style: TextStyle(
                color: _currentUserService.hasSapConfiguration 
                    ? Colors.green.shade700 
                    : null,
                fontWeight: _currentUserService.hasSapConfiguration 
                    ? FontWeight.bold 
                    : null,
              ),
              validator: !_currentUserService.hasSapConfiguration 
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el código de vendedor';
                      }
                      return null;
                    }
                  : null,
            ),
            
            // Información adicional del usuario
            if (_currentUserService.currentUser != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario: ${_currentUserService.currentUser!.name}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Email: ${_currentUserService.currentUser!.email}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    if (_currentUserService.currentUser!.almacenCode != null) ...[
                      Text(
                        'Almacén: ${_currentUserService.currentUser!.almacenCode}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
              ],
            ),
            const SizedBox(height: 12),
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
                      prefixIcon: Icon(Icons.place),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_hasLocationData ? Icons.refresh : Icons.my_location),
                label: Text(_isLoadingLocation
                    ? 'Obteniendo ubicación...'
                    : _hasLocationData
                        ? 'Actualizar Ubicación'
                        : 'Obtener Ubicación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasLocationData ? Colors.orange : null,
                ),
              ),
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
            WarehouseSelectorWidget(
              selectedWarehouse: _selectedWarehouse,
              onWarehouseSelected: (warehouse) {
                setState(() {
                  _selectedWarehouse = warehouse;
                  if (warehouse != null) {
                    _warehouseController.text = warehouse.whsCode;
                  } else {
                    _warehouseController.clear();
                  }
                });
              },
              labelText: 'Almacén por Defecto',
              hintText: _currentUserService.currentUser?.almacenCode != null
                  ? 'Por defecto: ${_currentUserService.currentUser!.almacenCode}'
                  : 'Seleccionar almacén',
              isRequired: false,
            ),
            if (_currentUserService.currentUser?.almacenCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Si no selecciona un almacén, se usará: ${_currentUserService.currentUser!.almacenCode}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
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
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentarios adicionales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Ingrese comentarios opcionales...',
              ),
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
                Icon(Icons.inventory_2, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Artículos *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Artículo'),
              ),
            ),
            if (_documentLines.isNotEmpty) ...[
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _documentLines.length,
                itemBuilder: (context, index) {
                  final item = _documentLines[index];
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
                                      item.itemCode,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(item.itemName),
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
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final quantity = double.tryParse(value) ?? 0.0;
                                    _updateItemQuantity(index, quantity);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.priceAfterVAT.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Precio',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final price = double.tryParse(value) ?? 0.0;
                                    _updateItemPrice(index, price);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '\${(item.quantity * item.priceAfterVAT).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total General: \${_calculateTotal().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
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

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _createSalesOrder,
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
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// Modelo para UserSerie ya se movió a su propio archivo models/user_serie.dart

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
      priceAfterVAT: 0.0,
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