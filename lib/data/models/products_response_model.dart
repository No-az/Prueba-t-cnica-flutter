import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'products_response_model.freezed.dart';
part 'products_response_model.g.dart';

@freezed
abstract class ProductsResponseModel with _$ProductsResponseModel {
  const factory ProductsResponseModel({
    required List<ProductModel> products,
    required int total,
    required int skip,
    required int limit,
  }) = _ProductsResponseModel;

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseModelFromJson(json);
}
