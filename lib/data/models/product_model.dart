import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required int id,
    required String title,
    @Default('') String description,
    required double price,
    @Default(0.0) double discountPercentage,
    @Default(0.0) double rating,
    @Default(0) int stock,
    @Default('') String brand,
    @Default('') String category,
    @Default('') String thumbnail,
    @Default([]) List<String> images,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

extension ProductModelMapper on ProductModel {
  Product toEntity() => Product(
        id: id,
        title: title,
        description: description,
        price: price,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        brand: brand,
        category: category,
        thumbnail: thumbnail,
        images: images,
      );
}

extension ProductEntityMapper on Product {
  ProductModel toModel() => ProductModel(
        id: id,
        title: title,
        description: description,
        price: price,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        brand: brand,
        category: category,
        thumbnail: thumbnail,
        images: images,
      );
}
