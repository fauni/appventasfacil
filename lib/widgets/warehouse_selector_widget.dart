// lib/widgets/warehouse_selector_widget.dart
import 'package:appventas/blocs/warehouse/warehouse_bloc.dart';
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:appventas/screens/warehouses/warehouse_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WarehouseSelectorWidget extends StatelessWidget {
  final Warehouse? selectedWarehouse;
  final Function(Warehouse?) onWarehouseSelected;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final bool enabled;

  const WarehouseSelectorWidget({
    Key? key,
    this.selectedWarehouse,
    required this.onWarehouseSelected,
    this.labelText = 'Almacén',
    this.hintText = 'Seleccionar almacén',
    this.isRequired = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<Warehouse>(
      initialValue: selectedWarehouse,
      validator: isRequired
          ? (value) => value == null ? 'Este campo es requerido' : null
          : null,
      builder: (FormFieldState<Warehouse> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: enabled ? () => _openWarehouseSelector(context, field) : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                  prefixIcon: const Icon(Icons.warehouse),
                  suffixIcon: enabled
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedWarehouse != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => _clearSelection(field),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        )
                      : null,
                  enabled: enabled,
                ),
                child: selectedWarehouse != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedWarehouse!.whsCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectedWarehouse!.whsName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        hintText ?? 'Seleccionar almacén',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openWarehouseSelector(BuildContext context, FormFieldState<Warehouse> field) async {
    final result = await Navigator.of(context).push<Warehouse>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<WarehouseBloc>(),
          child: WarehouseSelectionScreen(
            selectedWarehouse: selectedWarehouse,
            title: 'Seleccionar $labelText',
          ),
        ),
      ),
    );

    if (result != null) {
      field.didChange(result);
      onWarehouseSelected(result);
    }
  }

  void _clearSelection(FormFieldState<Warehouse> field) {
    field.didChange(null);
    onWarehouseSelected(null);
  }
}

// Widget alternativo más simple para casos básicos
class SimpleWarehouseSelectorWidget extends StatelessWidget {
  final Warehouse? selectedWarehouse;
  final Function(Warehouse?) onWarehouseSelected;
  final String? labelText;
  final bool enabled;

  const SimpleWarehouseSelectorWidget({
    Key? key,
    this.selectedWarehouse,
    required this.onWarehouseSelected,
    this.labelText = 'Almacén',
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.warehouse),
      title: Text(labelText ?? 'Almacén'),
      subtitle: selectedWarehouse != null
          ? Text(selectedWarehouse!.displayName)
          : const Text('Ningún almacén seleccionado'),
      trailing: enabled ? const Icon(Icons.arrow_forward_ios) : null,
      onTap: enabled ? () => _openWarehouseSelector(context) : null,
      enabled: enabled,
    );
  }

  void _openWarehouseSelector(BuildContext context) async {
    final result = await Navigator.of(context).push<Warehouse>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<WarehouseBloc>(),
          child: WarehouseSelectionScreen(
            selectedWarehouse: selectedWarehouse,
            title: 'Seleccionar $labelText',
          ),
        ),
      ),
    );

    if (result != null) {
      onWarehouseSelected(result);
    }
  }
}