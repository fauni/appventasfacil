// lib/screens/quotations/quotation_detail_screen.dart
import 'package:appventas/blocs/quotations/quotations_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_event.dart';
import 'package:appventas/blocs/quotations/quotations_state.dart';
import 'package:appventas/models/quotation/sales_quotation.dart';
import 'package:appventas/models/quotation/sales_quotation_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class QuotationDetailScreen extends StatefulWidget {
  final SalesQuotation quotation;

  const QuotationDetailScreen({
    Key? key,
    required this.quotation,
  }) : super(key: key);

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  bool _isLoadingDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotización #${widget.quotation.docNum ?? 'N/A'}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _shareQuotation(context),
            icon: const Icon(Icons.share),
            tooltip: 'Compartir información',
          ),
          IconButton(
            onPressed: widget.quotation.docEntry != null 
                ? () => _showPdfOptions(context)
                : null,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generar PDF',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'copy_number',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text('Copiar Número'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_code',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text('Copiar Código Cliente'),
                  ],
                ),
              ),
              if (widget.quotation.docEntry != null) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'pdf_preview',
                  child: Row(
                    children: [
                      Icon(Icons.preview, size: 18),
                      SizedBox(width: 8),
                      Text('Vista Previa PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf_share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Compartir PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf_print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 18),
                      SizedBox(width: 8),
                      Text('Imprimir PDF'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'convert_sale',
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, size: 18),
                      SizedBox(width: 8),
                      Text('Convertir a Venta'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listener para conversión a venta
          BlocListener<QuotationsBloc, QuotationsState>(
            listenWhen: (previous, current) => 
                current is QuotationConvertedToSale || 
                (current is QuotationsError && previous is QuotationsLoading),
            listener: (context, state) {
              if (state is QuotationConvertedToSale) {
                _showSuccessMessage(context, 'Cotización convertida a venta exitosamente');
                Navigator.of(context).pop();
              } else if (state is QuotationsError) {
                _showErrorMessage(context, state.message);
              }
            },
          ),
          
          // Listener para operaciones PDF
          BlocListener<QuotationsBloc, QuotationsState>(
            listenWhen: (previous, current) => 
                current is QuotationPdfLoading ||
                current is QuotationPdfPreviewSuccess ||
                current is QuotationPdfShareSuccess ||
                current is QuotationPdfPrintSuccess ||
                current is QuotationPdfError,
            listener: (context, state) {
              if (state is QuotationPdfLoading) {
                _showLoadingDialog(context, state.message);
              } else {
                _closeLoadingDialog(context);
                
                if (state is QuotationPdfShareSuccess) {
                  _showSuccessMessage(context, state.message);
                } else if (state is QuotationPdfError) {
                  _showErrorMessage(context, state.message);
                }
                // Para preview y print success no mostramos mensaje adicional
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(formatter),
              _buildCustomerSection(),
              _buildDocumentSection(dateFormatter),
              _buildTermsSection(),
              _buildAdditionalInfoSection(),
              _buildLinesSection(formatter),
              if (widget.quotation.docEntry != null)
                _buildConvertButton(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.quotation.docEntry != null 
          ? FloatingActionButton.extended(
              onPressed: () => _showPdfOptions(context),
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF'),
              tooltip: 'Generar PDF desde servidor',
            )
          : null,
    );
  }

  Widget _buildHeaderSection(NumberFormat formatter) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cotización #${widget.quotation.docNum ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Doc Entry: ${widget.quotation.docEntry ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    formatter.format(widget.quotation.docTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.quotation.cardName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCustomerSection() {
    return _buildSection(
      title: 'Información del Cliente',
      icon: Icons.person_outline,
      iconColor: Colors.blue[600]!,
      children: [
        _buildInfoTile(
          icon: Icons.badge,
          label: 'Código',
          value: widget.quotation.cardCode,
          isCopiable: true,
        ),
        _buildInfoTile(
          icon: Icons.business,
          label: 'Nombre',
          value: widget.quotation.cardName,
        ),
        if (widget.quotation.uLbRazonSocial != null && widget.quotation.uLbRazonSocial!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.corporate_fare,
            label: 'Razón Social',
            value: widget.quotation.uLbRazonSocial!,
          ),
        if (widget.quotation.uNit != null && widget.quotation.uNit!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.numbers,
            label: 'NIT',
            value: widget.quotation.uNit!,
            isCopiable: true,
          ),
        if (widget.quotation.slpCode != null && widget.quotation.slpCode!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.person_pin,
            label: 'Vendedor',
            value: widget.quotation.slpName != null && widget.quotation.slpName!.isNotEmpty
                ? '${widget.quotation.slpName} (Código: ${widget.quotation.slpCode})'
                : 'Código: ${widget.quotation.slpCode}',
          ),
      ],
    );
  }

  Widget _buildDocumentSection(DateFormat dateFormatter) {
    return _buildSection(
      title: 'Información del Documento',
      icon: Icons.description_outlined,
      iconColor: Colors.green[600]!,
      children: [
        _buildInfoTile(
          icon: Icons.calendar_today,
          label: 'Fecha Documento',
          value: dateFormatter.format(widget.quotation.docDate),
        ),
        _buildInfoTile(
          icon: Icons.event,
          label: 'Fecha Impuesto',
          value: dateFormatter.format(widget.quotation.taxDate),
        ),
        if (widget.quotation.comments != null && widget.quotation.comments!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.comment,
            label: 'Comentarios',
            value: widget.quotation.comments!,
            maxLines: 3,
          ),
      ],
    );
  }

  Widget _buildTermsSection() {
    final hasTerms = (widget.quotation.uVfTiempoEntrega != null && widget.quotation.uVfTiempoEntrega!.isNotEmpty) ||
                    (widget.quotation.uVfValidezOferta != null && widget.quotation.uVfValidezOferta!.isNotEmpty) ||
                    (widget.quotation.uVfFormaPago != null && widget.quotation.uVfFormaPago!.isNotEmpty);

    if (!hasTerms) return const SizedBox.shrink();

    return _buildSection(
      title: 'Términos y Condiciones',
      icon: Icons.assignment_outlined,
      iconColor: Colors.orange[600]!,
      children: [
        if (widget.quotation.uVfTiempoEntrega != null && widget.quotation.uVfTiempoEntrega!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.schedule,
            label: 'Tiempo de Entrega',
            value: _getDisplayValue(
              widget.quotation.uVfTiempoEntregaName, 
              widget.quotation.uVfTiempoEntrega
            ),
          ),
        if (widget.quotation.uVfValidezOferta != null && widget.quotation.uVfValidezOferta!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.timer,
            label: 'Validez de Oferta',
            value: _getDisplayValue(
              widget.quotation.uVfValidezOfertaName, 
              widget.quotation.uVfValidezOferta
            ),
          ),
        if (widget.quotation.uVfFormaPago != null && widget.quotation.uVfFormaPago!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.payment,
            label: 'Forma de Pago',
            value: _getDisplayValue(
              widget.quotation.uVfFormaPagoName, 
              widget.quotation.uVfFormaPago
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return _buildSection(
      title: 'Información Adicional',
      icon: Icons.info_outline,
      iconColor: Colors.purple[600]!,
      children: [
        _buildInfoTile(
          icon: Icons.phone_android,
          label: 'Registrado desde',
          value: 'Aplicación Móvil Flutter',
        ),
        _buildInfoTile(
          icon: Icons.cloud,
          label: 'PDF disponible',
          value: widget.quotation.docEntry != null 
              ? 'Generación desde servidor'
              : 'No disponible (sin DocEntry)',
        ),
      ],
    );
  }

  Widget _buildLinesSection(NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.indigo[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Productos (${widget.quotation.lines.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (widget.quotation.lines.isEmpty)
            Padding(
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
                    'No hay productos en esta cotización',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: widget.quotation.lines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final line = widget.quotation.lines[index];
                return _buildLineItem(line, formatter, index + 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isCopiable = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCopiable)
                      InkWell(
                        onTap: () => _copyToClipboard(context, value),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(SalesQuotationLine line, NumberFormat formatter, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.itemCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (line.description.isNotEmpty)
                      Text(
                        line.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                formatter.format(line.gTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildLineDetail('Cantidad', '${line.quantity}', Icons.numbers),
                const SizedBox(width: 16),
                _buildLineDetail('UOM', line.uomCode, Icons.straighten),
                const SizedBox(width: 16),
                _buildLineDetail('Precio', formatter.format(line.priceAfVat), Icons.attach_money),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineDetail(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConvertButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: BlocBuilder<QuotationsBloc, QuotationsState>(
        builder: (context, state) {
          final isLoading = state is QuotationsLoading;
          
          return ElevatedButton.icon(
            onPressed: isLoading ? null : () => _convertToSale(context, widget.quotation.docEntry!),
            icon: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.shopping_cart),
            label: Text(isLoading ? 'Convirtiendo...' : 'Convertir a Orden de Venta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isLoading ? 0 : 2,
            ),
          );
        },
      ),
    );
  }

  // Helper method para mostrar nombre + código o solo código
  String _getDisplayValue(String? name, String? code) {
    if (name != null && name.isNotEmpty) {
      return '$name (Código: $code)';
    }
    return 'Código: $code';
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'copy_number':
        _copyToClipboard(context, widget.quotation.docNum ?? '');
        _showSuccessMessage(context, 'Número de cotización copiado');
        break;
      case 'copy_code':
        _copyToClipboard(context, widget.quotation.cardCode);
        _showSuccessMessage(context, 'Código de cliente copiado');
        break;
      case 'pdf_preview':
        _previewPdf(context);
        break;
      case 'pdf_share':
        _sharePdf(context);
        break;
      case 'pdf_print':
        _printPdf(context);
        break;
      case 'convert_sale':
        if (widget.quotation.docEntry != null) {
          _convertToSale(context, widget.quotation.docEntry!);
        }
        break;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _shareQuotation(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ');
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    final text = '''
Cotización #${widget.quotation.docNum ?? 'N/A'}
Cliente: ${widget.quotation.cardName}
Código: ${widget.quotation.cardCode}
Fecha: ${dateFormatter.format(widget.quotation.docDate)}
Total: ${formatter.format(widget.quotation.docTotal)}
Productos: ${widget.quotation.lines.length}

Generado desde SAP Sales App
    ''';
    
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessMessage(context, 'Información de cotización copiada al portapapeles');
  }

  // MÉTODOS PDF USANDO BLOC
  void _previewPdf(BuildContext context) {
    if (widget.quotation.docEntry == null) {
      _showErrorMessage(context, 'No se puede generar PDF: DocEntry no disponible');
      return;
    }

    context.read<QuotationsBloc>().add(
      QuotationPdfPreviewRequested(widget.quotation.docEntry!, widget.quotation.docNum ?? 'N-A'),
    );
  }

  void _sharePdf(BuildContext context) {
    if (widget.quotation.docEntry == null) {
      _showErrorMessage(context, 'No se puede generar PDF: DocEntry no disponible');
      return;
    }

    context.read<QuotationsBloc>().add(
      QuotationPdfShareRequested(widget.quotation.docEntry!, widget.quotation.docNum ?? 'N-A'),
    );
  }

  void _printPdf(BuildContext context) {
    if (widget.quotation.docEntry == null) {
      _showErrorMessage(context, 'No se puede generar PDF: DocEntry no disponible');
      return;
    }

    context.read<QuotationsBloc>().add(
      QuotationPdfPrintRequested(widget.quotation.docEntry!, widget.quotation.docNum ?? 'N-A'),
    );
  }

  void _showPdfOptions(BuildContext context) {
    if (widget.quotation.docEntry == null) {
      _showErrorMessage(context, 'No se puede generar PDF: DocEntry no disponible');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.cloud_download, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'PDF desde Servidor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'DocEntry: ${widget.quotation.docEntry}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildPdfOption(
                context: context,
                icon: Icons.preview,
                title: 'Vista Previa',
                subtitle: 'Ver el PDF generado desde el servidor',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _previewPdf(context);
                },
              ),
              _buildPdfOption(
                context: context,
                icon: Icons.share,
                title: 'Compartir PDF',
                subtitle: 'Descargar y compartir desde servidor',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _sharePdf(context);
                },
              ),
              _buildPdfOption(
                context: context,
                icon: Icons.print,
                title: 'Imprimir',
                subtitle: 'Descargar e imprimir desde servidor',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _printPdf(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _convertToSale(BuildContext context, int docEntry) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text('Convertir a Venta'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Está seguro que desea convertir esta cotización en una orden de venta?',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<QuotationsBloc>().add(
                      QuotationConvertToSaleRequested(docEntry),
                    );
              },
              icon: const Icon(Icons.check),
              label: const Text('Convertir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // MÉTODOS PARA MANEJO DE LOADING DIALOG
  void _showLoadingDialog(BuildContext context, String message) {
    if (!_isLoadingDialogShown && mounted) {
      _isLoadingDialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor espere...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _closeLoadingDialog(BuildContext context) {
    if (_isLoadingDialogShown && mounted) {
      _isLoadingDialogShown = false;
      Navigator.of(context).pop();
    }
  }

  // MÉTODOS PARA MOSTRAR MENSAJES
  void _showSuccessMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}