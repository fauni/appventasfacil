import 'package:appventas/blocs/tfe_oum/tfe_uom_bloc.dart';
import 'package:appventas/blocs/tfe_oum/tfe_uom_event.dart';
import 'package:appventas/blocs/tfe_oum/tfe_uom_state.dart';
import 'package:appventas/models/item/tfe_unit_of_measure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TfeUomSelectionScreen extends StatefulWidget {
  final TfeUnitOfMeasure? initialTfeUom;
  
  const TfeUomSelectionScreen({
    Key? key,
    this.initialTfeUom,
  }) : super(key: key);

  @override
  State<TfeUomSelectionScreen> createState() => _TfeUomSelectionScreenState();
}

class _TfeUomSelectionScreenState extends State<TfeUomSelectionScreen> {
  TfeUnitOfMeasure? _selectedTfeUom;
  List<TfeUnitOfMeasure> _availableTfeUoms = [];

  @override
  void initState() {
    super.initState();
    _selectedTfeUom = widget.initialTfeUom;
    
    // Cargar TFE UoMs
    context.read<TfeUomBloc>().add(TfeUomLoadRequested());
  }

  void _selectTfeUom(TfeUnitOfMeasure tfeUom) {
    setState(() {
      _selectedTfeUom = tfeUom;
    });
    context.read<TfeUomBloc>().add(TfeUomSelected(tfeUom));
  }

  void _confirmSelection() {
    if (_selectedTfeUom != null) {
      Navigator.of(context).pop(_selectedTfeUom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Seleccionar Unidad de Medida de Venta'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          if (_selectedTfeUom != null)
            TextButton(
              onPressed: _confirmSelection,
              child: const Text(
                'SELECCIONAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con información
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border(
                bottom: BorderSide(color: Colors.orange[200]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unidades de Medida de Venta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona la unidad de medida para facturación',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Selección actual
          if (_selectedTfeUom != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionado:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedTfeUom!.displayText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Lista de TFE UoMs
          Expanded(
            child: BlocBuilder<TfeUomBloc, TfeUomState>(
              builder: (context, state) {
                if (state is TfeUomLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is TfeUomError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar unidades',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TfeUomBloc>().add(TfeUomLoadRequested());
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TfeUomLoaded) {
                  final tfeUnitsOfMeasure = state.tfeUnitsOfMeasure;

                  if (tfeUnitsOfMeasure.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.straighten,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay unidades disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tfeUnitsOfMeasure.length,
                    itemBuilder: (context, index) {
                      final tfeUom = tfeUnitsOfMeasure[index];
                      final isSelected = _selectedTfeUom?.code == tfeUom.code;
                      final isDefault = tfeUom.code == '80';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isSelected ? 4 : 1,
                        child: InkWell(
                          onTap: () => _selectTfeUom(tfeUom),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.orange[400]!, width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Indicador de selección
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? Colors.orange[600]! 
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected 
                                        ? Colors.orange[600] 
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                
                                // Información de la TFE UoM
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            tfeUom.code,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isSelected 
                                                  ? Colors.orange[700] 
                                                  : null,
                                            ),
                                          ),
                                          if (isDefault) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6, 
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[100],
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.green[300]!),
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
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tfeUom.name,
                                        style: TextStyle(
                                          color: isSelected 
                                              ? Colors.orange[600] 
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Arrow indicator
                                Icon(
                                  Icons.chevron_right,
                                  color: isSelected 
                                      ? Colors.orange[600] 
                                      : Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}