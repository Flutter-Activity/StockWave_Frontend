import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/order_providers.dart';
import '../providers/product_providers.dart';
import '../repositories/order_repository.dart';
import '../utils/price_calculator.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool loading = false;
  String? errorMessage;

  Future<void> _confirmOrder() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final cart = ref.read(cartProvider);
    final repo = ref.read(orderRepositoryProvider);

    try {
      final order = await repo.create(cart);
      ref.read(cartProvider.notifier).clear();
      if (mounted) context.go('/orders/${order.id}');
    } on ApiException catch (e) {
      setState(() => errorMessage = e.message);
      // refrescar stock desactualizado
      ref.invalidate(productsListProvider);
    } catch (e) {
      setState(() => errorMessage = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final totals = PriceCalculator.calculate(cart);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: cart
                    .map((c) => ListTile(
                          title: Text(c.product.name),
                          subtitle: Text('x${c.quantity}'),
                          trailing: Text('\$${(c.quantity * c.product.price).toStringAsFixed(0)}'),
                        ))
                    .toList(),
              ),
            ),
            Text('Subtotal: \$${totals.subtotal.toStringAsFixed(0)}'),
            Text('Descuento: -\$${totals.discount.toStringAsFixed(0)}'),
            Text('Total: \$${totals.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _confirmOrder,
                child: loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Confirmar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}