import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

final ordersListProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getAll();
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getById(id);
});