import '../../core/utils/either.dart';
import '../../core/error/failures.dart';
import '../entities/cart_item.dart';
import '../entities/product.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCartItems();
  Future<Either<Failure, void>> addItem(Product product, int quantity);
  Future<Either<Failure, void>> removeItem(int productId);
  Future<Either<Failure, void>> updateQuantity(int productId, int quantity);
  Future<Either<Failure, void>> clearCart();
}
