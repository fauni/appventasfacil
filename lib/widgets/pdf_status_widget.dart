// lib/widgets/pdf_status_widget.dart
import 'package:flutter/material.dart';
import 'package:appventas/services/pdf_report_service.dart';

class PdfStatusWidget extends StatefulWidget {
  final int? docEntry;
  final VoidCallback onPdfAvailable;

  const PdfStatusWidget({
    Key? key,
    required this.docEntry,
    required this.onPdfAvailable,
  }) : super(key: key);

  @override
  State<PdfStatusWidget> createState() => _PdfStatusWidgetState();
}

class _PdfStatusWidgetState extends State<PdfStatusWidget> {
  bool _isChecking = false;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkPdfAvailability();
  }

  Future<void> _checkPdfAvailability() async {
    if (widget.docEntry == null) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final isAvailable = await PdfReportService.isPdfAvailable(widget.docEntry!);
      if (mounted) {
        setState(() {
          _isAvailable = isAvailable;
          _isChecking = false;
        });

        if (isAvailable) {
          widget.onPdfAvailable();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAvailable = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.docEntry == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'PDF no disponible - DocEntry requerido',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_isChecking) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Verificando disponibilidad del PDF...',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isAvailable ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.warning,
            color: _isAvailable ? Colors.green[600] : Colors.orange[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isAvailable 
                  ? 'PDF disponible para descarga'
                  : 'PDF no disponible en el servidor',
              style: TextStyle(
                color: _isAvailable ? Colors.green[700] : Colors.orange[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!_isAvailable)
            TextButton(
              onPressed: _checkPdfAvailability,
              child: Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}