import '../../core/utils/either.dart';
import '../../core/error/failures.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<Either<Failure, List<CartItem>>> call() {
    return repository.getCartItems();
  }
}
