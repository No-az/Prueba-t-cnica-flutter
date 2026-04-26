import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/utils/constants.dart';
import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<ProductModel?> getCachedProduct(int id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Database db;

  ProductLocalDataSourceImpl(this.db);

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final rows = await db.query(AppConstants.productsTable);
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final batch = db.batch();
    for (final p in products) {
      batch.insert(
        AppConstants.productsTable,
        _modelToRow(p),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<ProductModel?> getCachedProduct(int id) async {
    final rows = await db.query(
      AppConstants.productsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToModel(rows.first);
  }

  Map<String, dynamic> _modelToRow(ProductModel m) => {
        'id': m.id,
        'title': m.title,
        'description': m.description,
        'price': m.price,
        'discountPercentage': m.discountPercentage,
        'rating': m.rating,
        'stock': m.stock,
        'brand': m.brand,
        'category': m.category,
        'thumbnail': m.thumbnail,
        'images': jsonEncode(m.images),
      };

  ProductModel _rowToModel(Map<String, dynamic> row) => ProductModel(
        id: row['id'] as int,
        title: row['title'] as String,
        description: row['description'] as String? ?? '',
        price: (row['price'] as num).toDouble(),
        discountPercentage: (row['discountPercentage'] as num?)?.toDouble() ?? 0,
        rating: (row['rating'] as num?)?.toDouble() ?? 0,
        stock: row['stock'] as int? ?? 0,
        brand: row['brand'] as String? ?? '',
        category: row['category'] as String? ?? '',
        thumbnail: row['thumbnail'] as String? ?? '',
        images: _decodeImages(row['images']),
      );

  List<String> _decodeImages(dynamic raw) {
    if (raw == null) return [];
    try {
      return (jsonDecode(raw as String) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
