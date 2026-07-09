class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final bool lowStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.lowStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        stock: json['stock'] as int,
        category: json['category'] as String,
        lowStock: json['lowStock'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
        'lowStock': lowStock,
      };
}