import 'package:dio/dio.dart';
import '../../models/product_model.dart';
import '../../models/products_response_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductsResponseModel> getProducts({required int skip, required int limit});
  Future<ProductModel> getProductDetail(int id);
  Future<ProductsResponseModel> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<ProductsResponseModel> getProducts({
    required int skip,
    required int limit,
  }) async {
    final response = await dio.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> getProductDetail(int id) async {
    final response = await dio.get('/products/$id');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductsResponseModel> searchProducts(String query) async {
    final response = await dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    return ProductsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
