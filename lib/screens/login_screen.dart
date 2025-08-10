import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/core/app_colors.dart'; // ✅ IMPORT AGREGADO
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../models/login_request.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final loginRequest = LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      context.read<AuthBloc>().add(AuthLoginRequested(loginRequest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ❌ ANTES: backgroundColor: Colors.grey[50],
      backgroundColor: AppColors.background, // ✅ MIGRADO
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                // ❌ ANTES: backgroundColor: Colors.red,
                backgroundColor: AppColors.error, // ✅ MIGRADO
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title Section - MIGRADO
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // ❌ ANTES: color: Colors.blue[600],
                        color: AppColors.primary, // ✅ MIGRADO
                        borderRadius: BorderRadius.circular(20),
                        // ✅ AGREGADO: Gradiente para mejor apariencia
                        gradient: LinearGradient(
                          colors: [AppColors.onPrimary, AppColors.onPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        // ✅ AGREGADO: Sombra sutil
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset('assets/logos/tomatefacilbanner.jpg', height: 80), // ✅ AGREGADO: Logo de la app
                          const SizedBox(height: 16),
                          Text(
                            'VENTAS FACIL APP',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              // ❌ ANTES: color: Colors.white,
                              color: AppColors.primary, // ✅ MIGRADO
                            ),
                          ),
                          Text(
                            'Cotizaciones y Ventas',
                            style: TextStyle(
                              fontSize: 16,
                              // ❌ ANTES: color: Colors.white70,
                              color: AppColors.primary.withOpacity(0.8), // ✅ MIGRADO
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Form - MIGRADO
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        // ❌ ANTES: color: Colors.white,
                        color: AppColors.surface, // ✅ MIGRADO
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ❌ ANTES: color: Colors.black.withOpacity(0.1),
                            color: AppColors.shadow, // ✅ MIGRADO
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                // ❌ ANTES: color: Colors.grey[800],
                                color: AppColors.onSurface, // ✅ MIGRADO
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Username Field - MIGRADO
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(
                                  Icons.person,
                                  // ✅ AGREGADO: Color del icono
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  // ❌ ANTES: borderSide: BorderSide(color: Colors.blue[600]!),
                                  borderSide: BorderSide(color: AppColors.primary), // ✅ MIGRADO
                                ),
                                // ✅ AGREGADO: Más estilos
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceVariant.withOpacity(0.3),
                                labelStyle: TextStyle(color: AppColors.textSecondary),
                              ),
                              style: TextStyle(color: AppColors.onSurface),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su usuario';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field - MIGRADO
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  // ✅ AGREGADO: Color del icono
                                  color: AppColors.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    // ✅ AGREGADO: Color del icono
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  // ❌ ANTES: borderSide: BorderSide(color: Colors.blue[600]!),
                                  borderSide: BorderSide(color: AppColors.primary), // ✅ MIGRADO
                                ),
                                // ✅ AGREGADO: Más estilos
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceVariant.withOpacity(0.3),
                                labelStyle: TextStyle(color: AppColors.textSecondary),
                              ),
                              style: TextStyle(color: AppColors.onSurface),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button - MIGRADO Y MEJORADO
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    // ✅ AGREGADO: Gradiente en el botón
                                    gradient: state is AuthLoading 
                                        ? null 
                                        : LinearGradient(
                                            colors: [AppColors.primary, AppColors.primaryLight],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                    // ✅ AGREGADO: Sombra del botón
                                    boxShadow: state is AuthLoading 
                                        ? null 
                                        : [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      // ❌ ANTES: backgroundColor: Colors.blue[600],
                                      backgroundColor: state is AuthLoading 
                                          ? AppColors.disabled 
                                          : Colors.transparent, // ✅ MIGRADO (transparente para mostrar gradiente)
                                      // ❌ ANTES: foregroundColor: Colors.white,
                                      foregroundColor: state is AuthLoading 
                                          ? AppColors.textSecondary 
                                          : AppColors.onPrimary, // ✅ MIGRADO
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0, // Sin elevación porque usamos boxShadow
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: state is AuthLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              // ❌ ANTES: valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                AppColors.primary, // ✅ MIGRADO
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Iniciar Sesión',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            
                            // ✅ AGREGADO: Link de ayuda (opcional)
                            const SizedBox(height: 16),
                            // TextButton(
                            //   onPressed: () {
                            //     // Mostrar ayuda o recuperar contraseña
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //         content: const Text('Contacte al administrador para ayuda'),
                            //         backgroundColor: AppColors.info,
                            //       ),
                            //     );
                            //   },
                            //   child: Text(
                            //     '¿Necesitas ayuda?',
                            //     style: TextStyle(
                            //       color: AppColors.primary,
                            //       fontSize: 14,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    
                    // ✅ AGREGADO: Footer informativo
                    const SizedBox(height: 24),
                    Text(
                      'Versión 1.0 - SAP Business One Integration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}