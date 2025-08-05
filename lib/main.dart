import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_bloc.dart';
import 'package:appventas/blocs/sales/sales_bloc.dart';
import 'package:appventas/blocs/terms_conditions/terms_conditions_bloc.dart';
import 'package:appventas/services/current_user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/uom/uom_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

import 'package:appventas/services/http_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar CurrentUserService
  final currentUserService = CurrentUserService();
  await currentUserService.loadCurrentUser();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context){
            final authBloc = AuthBloc()..add(AuthStatusChecked());
            HttpClient.setAuthBloc(authBloc);
            return authBloc;
          }
        ),
        BlocProvider<QuotationsBloc>(create: (context) => QuotationsBloc()),
        BlocProvider<SalesBloc>(create: (context) => SalesBloc()),
        BlocProvider<CustomerBloc>(create: (context) => CustomerBloc()), // Nuevo BlocProvider
        BlocProvider<ItemBloc>(create: (context) => ItemBloc()),
        BlocProvider<UomBloc>(create: (context) => UomBloc()), // Nuevo BlocProvider
        BlocProvider<TermsConditionsBloc>(create: (context) => TermsConditionsBloc()),
      ],
      child: MaterialApp(
        title: 'SAP Sales App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const SplashScreen();
            } else if (state is AuthAuthenticated) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.business,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SAP Sales App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cotizaciones y Ventas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
