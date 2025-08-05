import 'package:appventas/blocs/uom/uom_bloc.dart';
import 'package:appventas/blocs/uom/uom_event.dart';
import 'package:appventas/blocs/uom/uom_state.dart';
import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UomDropdown extends StatelessWidget {
  final String itemCode;
  final UnitOfMeasure? selectedUom;
  final Function(UnitOfMeasure?) onChanged;
  final bool enabled;
  final String? label;
  final String? helperText;
  final bool isRequired;

  const UomDropdown({
    Key? key,
    required this.itemCode,
    this.selectedUom,
    required this.onChanged,
    this.enabled = true,
    this.label = 'Unidad de Medida',
    this.helperText,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UomBloc, UomState>(
      builder: (context, state) {
        if (state is UomLoading && state.itemCode == itemCode) {
          return _buildLoadingDropdown();
        }

        if (state is UomLoaded && state.itemCode == itemCode) {
          return _buildDropdown(context, state.unitOfMeasures, state.selectedUom);
        }

        if (state is UomError && state.itemCode == itemCode) {
          return _buildErrorDropdown(context, state.message);
        }

        // Estado inicial o item diferente - mostrar dropdown deshabilitado
        return _buildDisabledDropdown();
      },
    );
  }

  Widget _buildLoadingDropdown() {
    return DropdownButtonFormField<UnitOfMeasure>(
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        helperText: helperText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: const SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      items: null,
      onChanged: null,
      hint: const Text('Cargando unidades...'),
    );
  }

  Widget _buildDropdown(BuildContext context, List<UnitOfMeasure> unitOfMeasures, UnitOfMeasure? currentSelected) {
    return DropdownButtonFormField<UnitOfMeasure>(
      value: currentSelected,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        helperText: helperText ?? '',// 'Unidad de medida del producto',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.straighten),
      ),
      items: unitOfMeasures.map((uom) {
        return DropdownMenuItem<UnitOfMeasure>(
          value: uom,
          child: Row(
            children: [
              Text(
                uom.uomCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  uom.uomName,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              if (uom.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Por defecto',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: enabled ? (uom) {
        if (uom != null) {
          context.read<UomBloc>().add(UomSelected(uom));
          onChanged(uom);
        }
      } : null,
      validator: isRequired ? (value) {
        if (value == null) {
          return 'Debe seleccionar una unidad de medida';
        }
        return null;
      } : null,
      hint: const Text('Seleccionar unidad'),
    );
  }

  Widget _buildErrorDropdown(BuildContext context, String errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<UnitOfMeasure>(
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            prefixIcon: const Icon(Icons.error, color: Colors.red),
          ),
          items: null,
          onChanged: null,
          hint: const Text('Error al cargar unidades'),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<UomBloc>().add(UomLoadRequested(itemCode));
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisabledDropdown() {
    return DropdownButtonFormField<UnitOfMeasure>(
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        helperText: helperText ?? 'Seleccione primero un item',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.straighten),
      ),
      items: null,
      onChanged: null,
      hint: const Text('Primero seleccione un item'),
    );
  }
}