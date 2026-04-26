import '../../core/utils/either.dart';
import '../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductDetailUseCase {
  final ProductRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, Product>> call(int id) {
    return repository.getProductDetail(id);
  }
}
