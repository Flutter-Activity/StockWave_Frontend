import '../models/cart_item.dart';

class PriceTotals {
  final double subtotal;
  final double discount;
  final double total;

  PriceTotals({required this.subtotal, required this.discount, required this.total});
}

// ÚNICA función que calcula precios en toda la app. Misma fórmula que el backend.
class PriceCalculator {
  static PriceTotals calculate(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0, (sum, item) => sum + (item.quantity * item.product.price),
    );
    final totalUnits = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final discount = totalUnits >= 5 ? subtotal * 0.10 : 0.0;
    final total = subtotal - discount;
    return PriceTotals(subtotal: subtotal, discount: discount, total: total);
  }
}