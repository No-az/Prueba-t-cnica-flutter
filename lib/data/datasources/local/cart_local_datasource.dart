import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/utils/constants.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

abstract class CartLocalDataSource {
  Future<List<CartItem>> getCartItems();
  Future<void> addItem(Product product, int quantity);
  Future<void> removeItem(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Database db;

  CartLocalDataSourceImpl(this.db);

  @override
  Future<List<CartItem>> getCartItems() async {
    final rows = await db.query(AppConstants.cartTable);
    return rows.map(_rowToCartItem).toList();
  }

  @override
  Future<void> addItem(Product product, int quantity) async {
    final existing = await db.query(
      AppConstants.cartTable,
      where: 'productId = ?',
      whereArgs: [product.id],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert(AppConstants.cartTable, _productToRow(product, quantity));
    } else {
      final current = existing.first['quantity'] as int;
      await db.update(
        AppConstants.cartTable,
        {'quantity': current + quantity},
        where: 'productId = ?',
        whereArgs: [product.id],
      );
    }
  }

  @override
  Future<void> removeItem(int productId) async {
    await db.delete(
      AppConstants.cartTable,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    await db.update(
      AppConstants.cartTable,
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<void> clearCart() async {
    await db.delete(AppConstants.cartTable);
  }

  Map<String, dynamic> _productToRow(Product p, int quantity) => {
        'productId': p.id,
        'title': p.title,
        'price': p.price,
        'discountPercentage': p.discountPercentage,
        'thumbnail': p.thumbnail,
        'quantity': quantity,
        'brand': p.brand,
        'category': p.category,
        'description': p.description,
        'rating': p.rating,
        'stock': p.stock,
        'images': jsonEncode(p.images),
      };

  CartItem _rowToCartItem(Map<String, dynamic> row) {
    final product = Product(
      id: row['productId'] as int,
      title: row['title'] as String,
      price: (row['price'] as num).toDouble(),
      discountPercentage: (row['discountPercentage'] as num?)?.toDouble() ?? 0,
      thumbnail: row['thumbnail'] as String? ?? '',
      brand: row['brand'] as String? ?? '',
      category: row['category'] as String? ?? '',
      description: row['description'] as String? ?? '',
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      stock: row['stock'] as int? ?? 0,
      images: _decodeImages(row['images']),
    );
    return CartItem(product: product, quantity: row['quantity'] as int);
  }

  List<String> _decodeImages(dynamic raw) {
    if (raw == null) return [];
    try {
      return (jsonDecode(raw as String) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
