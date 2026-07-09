import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_providers.dart';
import '../repositories/order_repository.dart';
import '../widgets/order_status_chip.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  static const nextStatus = {
    'pending': 'confirmed',
    'confirmed': 'shipped',
    'shipped': 'delivered',
  };

  bool actionLoading = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => actionLoading = true);
    final repo = ref.read(orderRepositoryProvider);
    try {
      await repo.updateStatus(widget.orderId, newStatus);
      ref.invalidate(orderDetailProvider(widget.orderId));
      ref.invalidate(ordersListProvider);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del pedido'),
        leading: context.canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())
            : IconButton(icon: const Icon(Icons.home), onPressed: () => context.go('/products')),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(widget.orderId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (order) {
          final canCancel = order.status == 'pending' || order.status == 'confirmed';
          final next = nextStatus[order.status];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pedido #${order.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.titleMedium),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: order.items
                        .map((i) => ListTile(
                              title: Text(i.productId),
                              subtitle: Text('x${i.quantity}'),
                              trailing: Text('\$${(i.quantity * i.unitPrice).toStringAsFixed(0)}'),
                            ))
                        .toList(),
                  ),
                ),
                Text('Subtotal: \$${order.subtotal.toStringAsFixed(0)}'),
                Text('Descuento: -\$${order.discount.toStringAsFixed(0)}'),
                Text('Total: \$${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (actionLoading) const Center(child: CircularProgressIndicator()),
                if (!actionLoading) ...[
                  if (next != null)
                    ElevatedButton(
                      onPressed: () => _updateStatus(next),
                      child: Text('Avanzar a "$next"'),
                    ),
                  if (canCancel)
                    TextButton(
                      onPressed: () => _updateStatus('cancelled'),
                      child: const Text('Cancelar pedido', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}