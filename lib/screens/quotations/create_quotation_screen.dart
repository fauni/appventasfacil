import 'package:appventas/blocs/customer/customer_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_event.dart';
import 'package:appventas/blocs/quotations/quotations_state.dart';
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/uom/uom_bloc.dart';
import 'package:appventas/blocs/uom/uom_event.dart';
import 'package:appventas/blocs/terms_conditions/terms_conditions_bloc.dart';
import 'package:appventas/blocs/terms_conditions/terms_conditions_event.dart';
import 'package:appventas/blocs/terms_conditions/terms_conditions_state.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/models/quotation/quotation_line_item.dart';
import 'package:appventas/models/quotation/sales_quotation_dto.dart';
import 'package:appventas/models/quotation/terms_conditions.dart';
import 'package:appventas/screens/customers/customer_selection_screen.dart';
import 'package:appventas/screens/items/item_selection_screen.dart';
import 'package:appventas/services/current_user_service.dart';
import 'package:appventas/widgets/uom_selector_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({Key? key}) : super(key: key);

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _salesPersonController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final _currentUserService = CurrentUserService();
  
  List<QuotationLineItem> _documentLines = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _hasLocationData = false;
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    // Cargar términos y condiciones al iniciar la pantalla
    context.read<TermsConditionsBloc>().add(TermsConditionsLoadRequested());
    // Obtener ubicación automáticamente
    _getCurrentLocation();
    // Inicializar el código de vendedor con los datos del usuario actual
    _initializeSalesPersonCode();
  }

  // Método para inicializar el código de vendedor
  void _initializeSalesPersonCode() async {
    await _currentUserService.loadCurrentUser();

    final currentUser = _currentUserService.currentUser;
    if (currentUser != null && currentUser.hasSapConfiguration) {
      // Si hay datos del vendedor SAP, mostrar solo el nombre
      if (_currentUserService.hasSalesPersonData) {
        _salesPersonController.text = _currentUserService.salesPersonFieldDisplay;
      } else {
        // Si no hay datos del vendedor, mostrar solo el código
        _salesPersonController.text = currentUser.employeeCodeDisplay;
      }
    }
  }

  // Método para obtener la ubicación actual
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationMessage('Los servicios de ubicación están deshabilitados.');
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationMessage('Permisos de ubicación denegados.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationMessage('Los permisos de ubicación están permanentemente denegados.');
        return;
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      // Llenar los campos automáticamente
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _hasLocationData = true;
      });

      _showLocationMessage('Ubicación obtenida correctamente', isSuccess: true);

    } catch (e) {
      _showLocationMessage('Error al obtener ubicación: ${e.toString()}');
      setState(() {
        _hasLocationData = false;
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Método para recargar ubicación manualmente
  Future<void> _refreshLocation() async {
    await _getCurrentLocation();
  }

  void _showLocationMessage(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.warning,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _salesPersonController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _addNewLine() {
    setState(() {
      _documentLines.add(QuotationLineItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemCode: '',
        selectedItem: null,
        quantity: 1.0,
        priceAfterVAT: 0.0,
        selectedUom: null,
      ));
    });
  }

  void _removeLine(int index) {
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

  Future<void> _selectItem(int index) async {
    final selectedItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ItemBloc>(),
          child: ItemSelectionScreen(
            initialItem: _documentLines[index].selectedItem,
          ),
        ),
      ),
    );

    if (selectedItem != null) {
      setState(() {
        _documentLines[index] = _documentLines[index].copyWith(
          itemCode: selectedItem.itemCode,
          selectedItem: selectedItem,
          selectedUom: null, // Reset UoM when item changes
        );
      });

      // Cargar UoMs para el nuevo item
      context.read<UomBloc>().add(UomLoadRequested(selectedItem.itemCode));
    }
  }

  void _onUomSelected(int index, UnitOfMeasure? uom) {
    setState(() {
      _documentLines[index] = _documentLines[index].copyWith(selectedUom: uom);
    });
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
        if (line.selectedItem == null) {
          _showErrorMessage('Seleccione un item para la línea ${i + 1}');
          return;
        }
        if (line.quantity <= 0 || line.priceAfterVAT < 0) {
          _showErrorMessage('Complete cantidad y precio para la línea ${i + 1}');
          return;
        }
        if (line.selectedUom == null) {
          _showErrorMessage('Seleccione la unidad de medida para la línea ${i + 1}');
          return;
        }
      }

      // Obtener los valores seleccionados de términos y condiciones
      final termsConditionsBloc = context.read<TermsConditionsBloc>();
      
      // Determinar el código de vendedor a enviar
      int salesPersonCode;
      if (_currentUserService.hasSalesPersonData) {
        // Si tenemos datos del vendedor SAP, usar el código del empleado
        salesPersonCode = _currentUserService.employeeCodeSap ?? 1;
      } else {
        // Si no hay datos SAP, usar lo que el usuario ingresó
        salesPersonCode = int.tryParse(_salesPersonController.text) ?? 1;
      }
      
    // Obtener el username del usuario actual
    final currentUser = _currentUserService.currentUser;
    final username = currentUser?.username ?? 'APP_FLUTTER';

      final quotationDto = SalesQuotationDto(
        cardCode: _selectedCustomer!.cardCode,
        comments: _commentsController.text.trim(),
        salesPersonCode: salesPersonCode,
        uUsrventafacil: username,
        uLatitud: _latitudeController.text.trim().isEmpty ? null : _latitudeController.text.trim(),
        uLongitud: _longitudeController.text.trim().isEmpty ? null : _longitudeController.text.trim(),
        uVfTiempoEntrega: termsConditionsBloc.selectedDeliveryTime?.code ?? '',
        uVfValidezOferta: termsConditionsBloc.selectedOfferValidity?.code ?? '',
        uVfFormaPago: termsConditionsBloc.selectedPaymentMethod?.code ?? '',
        uFecharegistroapp: DateTime.now(),
        uHoraregistroapp: DateTime.now(),
        documentLines: _documentLines.map((line) => SalesQuotationLineDto(
          itemCode: line.selectedItem!.itemCode,
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<QuotationsBloc, QuotationsState>(
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
          ),
          BlocListener<TermsConditionsBloc, TermsConditionsState>(
            listener: (context, state) {
              if (state is TermsConditionsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error cargando términos: ${state.message}'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
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
                          
                          // Terms and Conditions
                          _buildSectionHeader('Términos y Condiciones'),
                          _buildTermsSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Location (Hidden fields but automatic)
                          _buildSectionHeader('Ubicación GPS'),
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
                labelText: 'Código de Vendedor (Empleado SAP) *',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: _currentUserService.hasSalesPersonData
                    ? _currentUserService.salesPersonFieldDisplay
                    : _currentUserService.hasSapConfiguration 
                        ? 'Código: ${_currentUserService.employeeCodeDisplay}'
                        : 'Ej: 1',
                helperText: _currentUserService.hasSalesPersonData
                    ? 'Vendedor obtenido desde SAP'
                    : _currentUserService.hasSapConfiguration
                        ? 'Código obtenido del perfil del usuario'
                        : 'ID del vendedor en SAP',
                suffixIcon: _currentUserService.hasSapConfiguration
                    ? Icon(Icons.verified_user, color: Colors.green[600])
                    : null,
              ),
              keyboardType: _currentUserService.hasSalesPersonData 
                  ? TextInputType.text 
                  : TextInputType.number,
              readOnly: _currentUserService.hasSapConfiguration,
              style: TextStyle(
                color: _currentUserService.hasSapConfiguration 
                    ? Colors.green[700] 
                    : null,
                fontWeight: _currentUserService.hasSapConfiguration 
                    ? FontWeight.bold 
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El código de vendedor es requerido';
                }
                // Si no hay datos de vendedor SAP, validar que sea número
                if (!_currentUserService.hasSalesPersonData && int.tryParse(value) == null) {
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
    return BlocBuilder<TermsConditionsBloc, TermsConditionsState>(
      builder: (context, state) {
        if (state is TermsConditionsLoading) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando términos y condiciones...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TermsConditionsError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[400],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar términos y condiciones',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TermsConditionsBloc>().add(TermsConditionsLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! TermsConditionsLoaded) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[400],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay datos disponibles',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TermsConditionsBloc>().add(TermsConditionsLoadRequested());
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Cargar términos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final termsConditions = state.termsConditions;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Forma de Pago
                _buildTermDropdown<PaymentMethod>(
                  label: 'Forma de Pago',
                  icon: Icons.payment,
                  items: termsConditions.paymentMethods,
                  selectedItem: state.selectedPaymentMethod,
                  onChanged: (paymentMethod) {
                    context.read<TermsConditionsBloc>().add(
                      PaymentMethodSelected(paymentMethod!),
                    );
                  },
                  itemBuilder: (paymentMethod) => paymentMethod.displayText,
                ),
                const SizedBox(height: 16),
                
                // Tiempo de Entrega
                _buildTermDropdown<DeliveryTime>(
                  label: 'Tiempo de Entrega',
                  icon: Icons.schedule,
                  items: termsConditions.deliveryTimes,
                  selectedItem: state.selectedDeliveryTime,
                  onChanged: (deliveryTime) {
                    context.read<TermsConditionsBloc>().add(
                      DeliveryTimeSelected(deliveryTime!),
                    );
                  },
                  itemBuilder: (deliveryTime) => deliveryTime.displayText,
                ),
                const SizedBox(height: 16),
                
                // Validez de la Oferta
                _buildTermDropdown<OfferValidity>(
                  label: 'Validez de la Oferta',
                  icon: Icons.calendar_today,
                  items: termsConditions.offerValidities,
                  selectedItem: state.selectedOfferValidity,
                  onChanged: (offerValidity) {
                    context.read<TermsConditionsBloc>().add(
                      OfferValiditySelected(offerValidity!),
                    );
                  },
                  itemBuilder: (offerValidity) => offerValidity.displayText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermDropdown<T>({
    required String label,
    required IconData icon,
    required List<T> items,
    required T? selectedItem,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      value: selectedItem,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemBuilder(item),
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text('Seleccionar $label'),
      isExpanded: true,
      validator: (value) {
        if (value == null) {
          return 'Seleccione una opción';
        }
        return null;
      },
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono de estado
            Icon(
              _hasLocationData ? Icons.check_circle : Icons.location_off,
              color: _hasLocationData ? Colors.green[600] : Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            
            // Texto de estado
            Expanded(
              child: Text(
                _hasLocationData 
                    ? 'Ubicación GPS obtenida' 
                    : _isLoadingLocation 
                        ? 'Obteniendo ubicación...'
                        : 'No se pudo obtener la ubicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _hasLocationData ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ),
            
            // Botón o loading
            if (_isLoadingLocation)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              )
            else if (!_hasLocationData)
              ElevatedButton.icon(
                onPressed: _refreshLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos agregados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar productos a la cotización',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Producto ${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeLine(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  tooltip: 'Eliminar producto',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Item Selection Button
            InkWell(
              onTap: () => _selectItem(index),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: line.selectedItem == null 
                        ? Colors.red.withOpacity(0.5) 
                        : Colors.green[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: line.selectedItem == null 
                      ? Colors.grey[50] 
                      : Colors.green[50],
                ),
                child: line.selectedItem == null
                    ? Row(
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Colors.grey[600],
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seleccionar Item',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Toca para buscar y seleccionar un item',
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
                            size: 18,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.selectedItem!.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Código: ${line.selectedItem!.itemCode}',
                                  style: TextStyle(
                                    fontSize: 14,
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
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cambiar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // UoM Selection
            UomSelectorButton(
              itemCode: line.selectedItem?.itemCode ?? '',
              itemName: line.selectedItem?.displayName ?? '',
              selectedUom: line.selectedUom,
              onUomSelected: (uom) => _onUomSelected(index, uom),
              enabled: line.selectedItem != null,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            
            // Quantity and Price Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: line.quantity.toString(),
                    decoration: InputDecoration(
                      labelText: 'Cantidad *',
                      prefixIcon: const Icon(Icons.plus_one),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: line.selectedUom?.uomCode ?? '',
                      
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 0.0;
                      // FIX: Preservar selectedUom al cambiar cantidad
                      final currentUom = _documentLines[index].selectedUom;
                      setState(() {
                        _documentLines[index] = _documentLines[index].copyWith(
                          quantity: quantity,
                          selectedUom: currentUom, // Preservar explícitamente
                        );
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
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: line.priceAfterVAT.toString(),
                    decoration: InputDecoration(
                      labelText: 'Precio *',
                      prefixIcon: const Icon(Icons.money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixText: 'Bs. ',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      // FIX: Preservar selectedUom al cambiar precio
                      final currentUom = _documentLines[index].selectedUom;
                      setState(() {
                        _documentLines[index] = _documentLines[index].copyWith(
                          priceAfterVAT: price,
                          selectedUom: currentUom, // Preservar explícitamente
                        );
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Line Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de esta línea:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${line.quantity} x Bs. ${NumberFormat('#,##0.00').format(line.priceAfterVAT)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Bs. ${NumberFormat('#,##0.00').format(line.quantity * line.priceAfterVAT)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 18,
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
}