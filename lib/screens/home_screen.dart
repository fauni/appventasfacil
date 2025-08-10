// lib/screens/home_screen.dart - MIGRADO
import 'package:appventas/screens/quotations/quotations_screen.dart';
import 'package:appventas/screens/sales/sales_screen.dart';
import 'package:appventas/screens/sales_order/sales_orders_screen.dart'; 
import 'package:appventas/core/app_colors.dart'; // ✅ IMPORT AGREGADO
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const QuotationsScreen(),
    const SalesOrdersScreen(), // ✅ AGREGADO
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ventas App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // ❌ ANTES: color: Colors.white,
              color: Colors.white, // ✅ OK - funciona con cualquier tema
            ),
          ),
          // ❌ ANTES: backgroundColor: Colors.blue[600],
          backgroundColor: AppColors.primaryDark, // ✅ MIGRADO
          elevation: 0,
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return PopupMenuButton(
                    // ❌ ANTES: icon: const Icon(Icons.account_circle, color: Colors.white),
                    icon: Icon(Icons.account_circle, color: AppColors.onPrimary), // ✅ MIGRADO
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 8),
                            Text(state.user.name),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.email, size: 18),
                            const SizedBox(width: 8),
                            Text(state.user.email),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        onTap: _logout,
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Cerrar Sesión'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // ✅ PARA 4 TABS
          // ❌ ANTES: selectedItemColor: Colors.blue[600],
          selectedItemColor: AppColors.primary, // ✅ MIGRADO
          // ❌ ANTES: unselectedItemColor: Colors.grey,
          unselectedItemColor: AppColors.textSecondary, // ✅ MIGRADO
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Cotizaciones',
            ),
            BottomNavigationBarItem( // ✅ AGREGADO
              icon: Icon(Icons.receipt_long),
              label: 'Órdenes',
            ),
          ],
        ),
      ),
    );
  }
}