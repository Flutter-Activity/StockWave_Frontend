import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_chip.dart';

class OrdersHistoryScreen extends ConsumerWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        leading: context.canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())
            : IconButton(icon: const Icon(Icons.home), onPressed: () => context.go('/products')),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(ordersListProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (orders) => ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i];
            return ListTile(
              title: Text('Pedido #${o.id.substring(0, 8)}'),
              subtitle: Text('\$${o.total.toStringAsFixed(0)}'),
              trailing: OrderStatusChip(status: o.status),
              onTap: () => context.push('/orders/${o.id}'),
            );
          },
        ),
      ),
    );
  }
}