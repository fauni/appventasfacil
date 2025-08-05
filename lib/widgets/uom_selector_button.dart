// lib/widgets/uom_selector_button.dart
// Widget botón para seleccionar UoM que abre la pantalla completa
import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/screens/items/uom_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/blocs/uom/uom_bloc.dart';
import 'package:appventas/blocs/uom/uom_event.dart';
import 'package:appventas/blocs/uom/uom_state.dart';

class UomSelectorButton extends StatefulWidget {
  final String itemCode;
  final String itemName;
  final UnitOfMeasure? selectedUom;
  final Function(UnitOfMeasure?) onUomSelected;
  final bool enabled;
  final bool isRequired;

  const UomSelectorButton({
    Key? key,
    required this.itemCode,
    required this.itemName,
    this.selectedUom,
    required this.onUomSelected,
    this.enabled = true,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<UomSelectorButton> createState() => _UomSelectorButtonState();
}

class _UomSelectorButtonState extends State<UomSelectorButton> {
  @override
  void initState() {
    super.initState();
    // Cargar UoMs cuando el widget se inicializa con un itemCode
    if (widget.itemCode.isNotEmpty && widget.enabled) {
      context.read<UomBloc>().add(UomLoadRequested(widget.itemCode));
    }
  }

  @override
  void didUpdateWidget(UomSelectorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cargar UoMs cuando cambia el itemCode
    if (widget.itemCode != oldWidget.itemCode && 
        widget.itemCode.isNotEmpty && 
        widget.enabled) {
      context.read<UomBloc>().add(UomLoadRequested(widget.itemCode));
    }
  }

  Future<void> _openUomSelection() async {
    if (!widget.enabled || widget.itemCode.isEmpty) return;

    final selectedUom = await Navigator.of(context).push<UnitOfMeasure>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<UomBloc>(),
          child: UomSelectionScreen(
            itemCode: widget.itemCode,
            itemName: widget.itemName,
            initialUom: widget.selectedUom,
          ),
        ),
      ),
    );

    if (selectedUom != null) {
      widget.onUomSelected(selectedUom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UomBloc, UomState>(
      builder: (context, state) {
        bool isLoading = false;
        bool hasError = false;
        String? errorMessage;

        if (state is UomLoading && state.itemCode == widget.itemCode) {
          isLoading = true;
        } else if (state is UomError && state.itemCode == widget.itemCode) {
          hasError = true;
          errorMessage = state.message;
        }

        return Container(
          width: double.infinity,
          child: InkWell(
            onTap: widget.enabled && !isLoading ? _openUomSelection : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError
                      ? Colors.red
                      : widget.selectedUom == null && widget.isRequired
                          ? Colors.red.withOpacity(0.5)
                          : widget.selectedUom != null
                              ? Colors.blue[200]!
                              : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
                color: !widget.enabled
                    ? Colors.grey[100]
                    : hasError
                        ? Colors.red[50]
                        : widget.selectedUom != null
                            ? Colors.blue[50]
                            : Colors.grey[50],
              ),
              child: widget.selectedUom == null
                  ? Row(
                      children: [
                        if (isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                            ),
                          )
                        else
                          Icon(
                            hasError
                                ? Icons.error
                                : widget.enabled && widget.itemCode.isNotEmpty
                                    ? Icons.straighten
                                    : Icons.block,
                            color: hasError
                                ? Colors.red
                                : !widget.enabled || widget.itemCode.isEmpty
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isRequired ? 'Unidad de Medida *' : 'Unidad de Medida',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: hasError
                                      ? Colors.red[700]
                                      : !widget.enabled || widget.itemCode.isEmpty
                                          ? Colors.grey[500]
                                          : Colors.grey[700],
                                ),
                              ),
                              Text(
                                isLoading
                                    ? 'Cargando unidades...'
                                    : hasError
                                        ? errorMessage ?? 'Error al cargar'
                                        : !widget.enabled
                                            ? 'Campo deshabilitado'
                                            : widget.itemCode.isEmpty
                                                ? 'Primero seleccione un item'
                                                : 'Toca para seleccionar unidad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasError
                                      ? Colors.red[600]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.enabled && widget.itemCode.isNotEmpty && !isLoading)
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              widget.selectedUom!.uomCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selectedUom!.uomName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Código: ${widget.selectedUom!.uomCode}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Conversión: ${widget.selectedUom!.baseQty}:${widget.selectedUom!.altQty}',
                                style: TextStyle(
                                  fontSize: 11,
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
                            const SizedBox(height: 2),
                            if (widget.enabled)
                              Text(
                                'Cambiar',
                                style: TextStyle(
                                  fontSize: 10,
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
      },
    );
  }
}