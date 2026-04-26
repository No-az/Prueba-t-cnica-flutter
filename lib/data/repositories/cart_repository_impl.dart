import '../../core/error/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/local/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final items = await localDataSource.getCartItems();
      return right(items);
    } catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addItem(Product product, int quantity) async {
    try {
      await localDataSource.addItem(product, quantity);
      return right(null);
    } catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(int productId) async {
    try {
      await localDataSource.removeItem(productId);
      return right(null);
    } catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(int productId, int quantity) async {
    try {
      await localDataSource.updateQuantity(productId, quantity);
      return right(null);
    } catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return right(null);
    } catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }
}
