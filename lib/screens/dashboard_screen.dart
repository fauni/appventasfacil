import 'package:appventas/screens/quotations/create_quotation_screen.dart';
import 'package:appventas/screens/sales_order/create_sales_order_screen.dart'; // NUEVO IMPORT
import 'package:appventas/blocs/sales_order/sales_order_bloc.dart'; // NUEVO IMPORT
import 'package:appventas/blocs/sales_order/sales_order_state.dart'; // NUEVO IMPORT
import 'package:appventas/blocs/sales_order/sales_order_event.dart'; // NUEVO IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/item/item_bloc.dart';
import '../blocs/uom/uom_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos de órdenes al inicializar el dashboard
    context.read<SalesOrderBloc>().add(SalesOrderLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Cambiado de Padding a SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section (existente)
          _buildWelcomeSection(),
          const SizedBox(height: 24),

          // ======= NUEVA SECCIÓN: ESTADÍSTICAS =======
          Text(
            'Resumen del Día',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Grid de estadísticas
          _buildStatsSection(),
          const SizedBox(height: 24),

          // Quick Actions (existente, pero modificado)
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Primera fila de acciones rápidas (modificada)
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Nueva Cotización',
                  subtitle: 'Crear cotización',
                  icon: Icons.add_box,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateQuotationScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // ======= NUEVA ACCIÓN: CREAR ORDEN =======
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Nueva Orden',
                  subtitle: 'Crear orden de venta',
                  icon: Icons.receipt_long,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<SalesOrderBloc>()),
                            BlocProvider.value(value: context.read<CustomerBloc>()),
                            BlocProvider.value(value: context.read<ItemBloc>()),
                            BlocProvider.value(value: context.read<UomBloc>()),
                          ],
                          child: const CreateSalesOrderScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segunda fila de acciones rápidas (existente)
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Ver Cotizaciones',
                  subtitle: 'Lista completa',
                  icon: Icons.list_alt,
                  color: Colors.blue,
                  onTap: () {
                    // Cambiar al tab de cotizaciones
                    _navigateToTab(context, 1);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // ======= NUEVA ACCIÓN: VER ÓRDENES =======
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Ver Órdenes',
                  subtitle: 'Lista de órdenes',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  onTap: () {
                    // Cambiar al tab de órdenes (index 3)
                    _navigateToTab(context, 3);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity (existente)
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  // ======= NUEVO MÉTODO: ESTADÍSTICAS =======
  Widget _buildStatsSection() {
    return Column(
      children: [
        // Primera fila de estadísticas
        Row(
          children: [
            Expanded(child: _buildQuotationsStatsCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildOrdersStatsCard()), // ← AQUÍ SE USA EL MÉTODO
          ],
        ),
        const SizedBox(height: 12),
        // Segunda fila de estadísticas (opcional)
        Row(
          children: [
            Expanded(child: _buildSalesStatsCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildGeneralStatsCard()),
          ],
        ),
      ],
    );
  }

  // ======= AQUÍ ESTÁ EL MÉTODO QUE PREGUNTASTE =======
  Widget _buildOrdersStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.purple[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Órdenes de Venta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SalesOrderBloc, SalesOrderState>(
              builder: (context, state) {
                if (state is SalesOrderLoading) {
                  return const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                
                if (state is SalesOrderLoaded) {
                  final orders = state.salesOrders;
                  final openOrders = orders.where((o) => 
                    o.docStatus.toLowerCase() == 'o' || o.docStatus.toLowerCase() == 'open'
                  ).length;
                  final totalAmount = orders.fold<double>(0, (sum, order) => sum + order.docTotal);
                  
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Abiertas:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            openOrders.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            'Bs. ${totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                
                if (state is SalesOrderError) {
                  return Text(
                    'Error al cargar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  );
                }
                
                return const Text(
                  'Sin datos',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Otros métodos de estadísticas para completar la cuadrícula
  Widget _buildQuotationsStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cotizaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Aquí podrías integrar el QuotationsBloc si existe
            const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pendientes:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Este mes:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '12',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ventas del Mes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Meta:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      'Bs. 50,000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Logrado:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '68%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Actividad Hoy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Documentos:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '8',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clientes:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares existentes (actualizados)
  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  state.user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipo de usuario: ${state.user.type}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No hay actividad reciente',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    // Buscar el HomeScreen padre y cambiar de tab
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    
    // Aquí necesitarías una forma de comunicarte con HomeScreen
    // Una opción es usar un callback o un Provider/Bloc global
    // Por simplicidad, mostraré un SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a la sección correspondiente...'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}