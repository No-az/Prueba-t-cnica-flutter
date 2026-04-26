import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    required int page,
    required int limit,
  }) async {
    final skip = page * limit;
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getProducts(
          skip: skip,
          limit: limit,
        );
        final products = response.products;
        await localDataSource.cacheProducts(products);
        return right(products.map((m) => m.toEntity()).toList());
      } on DioException catch (e) {
        return left(_mapDioError(e));
      } catch (e) {
        return left(Failure.unknown(message: e.toString()));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedProducts();
        return right(cached.map((m) => m.toEntity()).toList());
      } catch (e) {
        return left(const Failure.cache(message: 'No cached data available'));
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetail(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getProductDetail(id);
        return right(model.toEntity());
      } on DioException catch (e) {
        return left(_mapDioError(e));
      }
    } else {
      final cached = await localDataSource.getCachedProduct(id);
      if (cached != null) return right(cached.toEntity());
      return left(const Failure.network(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    if (!await networkInfo.isConnected) {
      return left(const Failure.network(message: 'No internet connection'));
    }
    try {
      final response = await remoteDataSource.searchProducts(query);
      return right(response.products.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return left(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        const Failure.timeout(message: 'Request timed out'),
      DioExceptionType.connectionError =>
        const Failure.network(message: 'No internet connection'),
      DioExceptionType.badResponse => () {
          final code = e.response?.statusCode ?? 0;
          if (code == 404) return Failure.notFound(message: 'Resource not found');
          return Failure.server(statusCode: code, message: e.message ?? 'Server error');
        }(),
      _ => Failure.unknown(message: e.message ?? 'Unknown error'),
    };
  }
}
