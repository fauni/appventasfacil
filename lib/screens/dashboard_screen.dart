// lib/screens/dashboard_screen.dart - MIGRADO
import 'package:appventas/screens/quotations/create_quotation_screen.dart';
import 'package:appventas/screens/quotations/create_quotation_screen_with_autocomplete.dart';
import 'package:appventas/screens/sales_order/create_sales_order_screen.dart'; // ✅ AGREGADO
import 'package:appventas/blocs/sales_order/sales_order_bloc.dart'; // ✅ AGREGADO
import 'package:appventas/blocs/sales_order/sales_order_state.dart'; // ✅ AGREGADO
import 'package:appventas/blocs/sales_order/sales_order_event.dart'; // ✅ AGREGADO
import 'package:appventas/core/app_colors.dart'; // ✅ IMPORT AGREGADO
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
    // ✅ AGREGADO: Cargar datos de órdenes
    context.read<SalesOrderBloc>().add(SalesOrderLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ✅ CAMBIADO: Para scroll
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section - MIGRADO
          _buildWelcomeSection(),
          const SizedBox(height: 24),

          // ✅ NUEVA SECCIÓN: Estadísticas
          _buildStatsSection(),
          const SizedBox(height: 24),

          // Quick Actions - MIGRADO Y EXPANDIDO
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // ❌ ANTES: color: Colors.grey[800],
              color: AppColors.onBackground, // ✅ MIGRADO
            ),
          ),
          const SizedBox(height: 16),

          // Primera fila de acciones
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Nueva Cotización',
                  subtitle: 'Crear cotización',
                  icon: Icons.add_box,
                  // ❌ ANTES: color: Colors.green,
                  color: AppColors.success, // ✅ MIGRADO
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
              // ✅ NUEVA ACCIÓN: Crear Orden
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Nueva Orden',
                  subtitle: 'Crear orden de venta',
                  icon: Icons.receipt_long,
                  color: AppColors.salesOrders, // ✅ COLOR ESPECÍFICO
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

          // Segunda fila de acciones
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Ver Cotizaciones',
                  subtitle: 'Lista completa',
                  icon: Icons.list_alt,
                  // ❌ ANTES: color: Colors.blue,
                  color: AppColors.quotations, // ✅ MIGRADO
                  onTap: () {
                    // Navegar al tab de cotizaciones
                    _showNavigationMessage(context, 'Cotizaciones');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  title: 'Ver Ventas',
                  subtitle: 'Órdenes de venta',
                  icon: Icons.shopping_cart,
                  // ❌ ANTES: color: Colors.orange,
                  color: AppColors.sales, // ✅ MIGRADO
                  onTap: () {
                    _showNavigationMessage(context, 'Ventas');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NUEVA SECCIÓN: Estadísticas
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Día',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground, // ✅ MIGRADO
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildQuotationsStatsCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildOrdersStatsCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildQuotationsStatsCard() {
    return Card(
      elevation: 2,
      color: AppColors.surface, // ✅ MIGRADO
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
                    // ❌ ANTES: color: Colors.blue[100],
                    color: AppColors.quotations.withOpacity(0.1), // ✅ MIGRADO
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description,
                    // ❌ ANTES: color: Colors.blue[600],
                    color: AppColors.quotations, // ✅ MIGRADO
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cotizaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.onSurface, // ✅ MIGRADO
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
                    Text(
                      'Pendientes:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary), // ✅ MIGRADO
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onSurface, // ✅ MIGRADO
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Este mes:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary), // ✅ MIGRADO
                    ),
                    Text(
                      '12',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.onSurface, // ✅ MIGRADO
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

  // ✅ NUEVA FUNCIÓN: Card de órdenes de venta
  Widget _buildOrdersStatsCard() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
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
                    color: AppColors.salesOrders.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.salesOrders,
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
                          Text(
                            'Abiertas:',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            openOrders.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            'Bs. ${totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                
                return Text(
                  'Sin datos',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ❌ ANTES: colors: [Colors.blue[600]!, Colors.blue[400]!],
                colors: [AppColors.primary, AppColors.primaryLight], // ✅ MIGRADO
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido,',
                  style: TextStyle(
                    fontSize: 16,
                    // ❌ ANTES: color: Colors.white70,
                    color: AppColors.onPrimary.withOpacity(0.7), // ✅ MIGRADO
                  ),
                ),
                Text(
                  state.user.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    // ❌ ANTES: color: Colors.white,
                    color: AppColors.onPrimary, // ✅ MIGRADO
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipo de usuario: ${state.user.type}',
                  style: TextStyle(
                    fontSize: 14,
                    // ❌ ANTES: color: Colors.white70,
                    color: AppColors.onPrimary.withOpacity(0.7), // ✅ MIGRADO
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
          // ❌ ANTES: color: Colors.white,
          color: AppColors.surface, // ✅ MIGRADO
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ❌ ANTES: color: Colors.black.withOpacity(0.05),
              color: AppColors.shadow, // ✅ MIGRADO
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface, // ✅ MIGRADO
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                // ❌ ANTES: color: Colors.grey[600],
                color: AppColors.textSecondary, // ✅ MIGRADO
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNavigationMessage(BuildContext context, String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a $section...'),
        // ❌ ANTES: backgroundColor: Colors.blue,
        backgroundColor: AppColors.primary, // ✅ MIGRADO
        action: SnackBarAction(
          label: 'OK',
          // ❌ ANTES: textColor: Colors.white,
          textColor: AppColors.onPrimary, // ✅ MIGRADO
          onPressed: () {},
        ),
      ),
    );
  }
}