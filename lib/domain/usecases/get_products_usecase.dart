import '../../core/utils/either.dart';
import '../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({
    required int page,
    required int limit,
  }) {
    return repository.getProducts(page: page, limit: limit);
  }
}
