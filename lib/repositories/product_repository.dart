import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductRepository {
  static const baseUrl = 'http://10.0.120.3:5000';

  Future<List<Product>> getAll() async {
    final res = await http.get(Uri.parse('$baseUrl/products'));
    if (res.statusCode != 200) {
      throw Exception('Error cargando productos (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getById(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (res.statusCode != 200) {
      throw Exception('Producto no encontrado (${res.statusCode})');
    }
    return Product.fromJson(jsonDecode(res.body));
  }
}