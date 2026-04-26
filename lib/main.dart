import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection.dart';
import 'presentation/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    const ProviderScope(child: InterCommerceApp()),
  );
}

class InterCommerceApp extends StatelessWidget {
  const InterCommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InterCommerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E88E5),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
