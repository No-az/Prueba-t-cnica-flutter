import 'package:go_router/go_router.dart';
import '../pages/catalog/catalog_page.dart';
import '../pages/detail/product_detail_page.dart';
import '../pages/cart/cart_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/catalog',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailPage(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
    ],
  );
}
