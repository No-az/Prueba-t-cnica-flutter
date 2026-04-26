import '../../core/utils/either.dart';
import '../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemUseCase {
  final CartRepository repository;

  UpdateCartItemUseCase(this.repository);

  Future<Either<Failure, void>> call(int productId, int quantity) {
    if (quantity <= 0) return repository.removeItem(productId);
    return repository.updateQuantity(productId, quantity);
  }
}
