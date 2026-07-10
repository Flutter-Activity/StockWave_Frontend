import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';

class ApiException implements Exception {
  final String message;
  final dynamic details;
  ApiException(this.message, [this.details]);
}

class OrderRepository {
  static const baseUrl = 'https://2m6ni1r2h5.execute-api.us-east-1.amazonaws.com/Prod';

  Future<List<Order>> getAll() async {
    final res = await http.get(Uri.parse('$baseUrl/orders'));
    if (res.statusCode != 200) {
      throw Exception('Error cargando pedidos (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> getById(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/orders/$id'));
    if (res.statusCode != 200) {
      throw Exception('Pedido no encontrado (${res.statusCode})');
    }
    return Order.fromJson(jsonDecode(res.body));
  }

  Future<Order> create(List<CartItem> items) async {
    final body = jsonEncode({
      'items': items
          .map((c) => {'productId': c.product.id, 'quantity': c.quantity})
          .toList(),
    });

    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode == 400) {
      throw ApiException(decoded['message'] ?? 'Error de validación', decoded['details']);
    }
    if (res.statusCode != 201) {
      throw ApiException('Error inesperado creando el pedido (${res.statusCode})');
    }

    return Order.fromJson(decoded);
  }

  Future<Order> updateStatus(String id, String newStatus) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode == 400) {
      throw ApiException(decoded['message'] ?? 'Transición inválida');
    }
    if (res.statusCode != 200) {
      throw ApiException('Error inesperado actualizando el estado (${res.statusCode})');
    }

    return Order.fromJson(decoded);
  }
}