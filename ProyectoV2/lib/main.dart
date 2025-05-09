import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tienda_ropas/screens/autentificacion/register_screen.dart';
import 'package:tienda_ropas/screens/autentificacion/reset_password_screen.dart';
import 'package:tienda_ropas/screens/autentificacion/role_selecctor_screen.dart';
import 'package:tienda_ropas/screens/cliente/home_cliente_screen.dart';
import 'package:tienda_ropas/screens/vendedor/home_vendedor_screen.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_add_product_page%20.dart';

import 'services/auth_service.dart';
import 'screens/autentificacion/login_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart'; // 💡 importante
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tienda Ropas',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
          initialRoute: AppRoutes.roleSelector, // correcto en tu caso
       // 👈 Cambiado
        routes: {
          
          AppRoutes.roleSelector: (_) => const RoleSelectorScreen(), // 👈 Nueva ruta
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),
          AppRoutes.clientHome: (_) => const HomeClientScreen(),
          AppRoutes.sellerHome: (_) => const HomeSellerScreen(),
          AppRoutes.sellerAddProduct: (_) => const SellerAddProductPage(),

        },
      ),
    );
  }
}
