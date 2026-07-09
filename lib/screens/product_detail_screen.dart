import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../providers/cart_provider.dart';
import '../widgets/low_stock_badge.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(productDetailProvider(widget.productId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (product) {
          if (quantity > product.stock) quantity = product.stock > 0 ? 1 : 0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('\$${product.price.toStringAsFixed(0)}'),
                Text('Categoría: ${product.category}'),
                Text('Stock disponible: ${product.stock}'),
                if (product.lowStock) const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LowStockBadge(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: quantity < product.stock ? () => setState(() => quantity++) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: product.stock == 0
                      ? null
                      : () {
                          ref.read(cartProvider.notifier).add(product, quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Agregado al carrito')),
                          );
                        },
                  child: const Text('Agregar al carrito'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}