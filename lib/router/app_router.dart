import 'package:go_router/go_router.dart';
import '../screens/products_list_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/orders_history_screen.dart';
import '../screens/order_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/products',
  routes: [
    GoRoute(path: '/products', builder: (context, state) => const ProductsListScreen()),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersHistoryScreen()),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
    ),
  ],
);