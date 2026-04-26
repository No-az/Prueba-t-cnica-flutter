import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_usecase.dart';

class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final UpdateCartItemUseCase _updateItem;

  CartNotifier(
    this._getCart,
    this._addToCart,
    this._removeFromCart,
    this._updateItem,
  ) : super(const AsyncValue.loading()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final result = await _getCart();
    result.fold(
      (f) => state = AsyncValue.error(f, StackTrace.current),
      (items) => state = AsyncValue.data(Cart(items: items)),
    );
  }

  Future<void> addToCart(Product product) async {
    final result = await _addToCart(product);
    if (result.isRight) await _loadCart();
  }

  Future<void> removeFromCart(int productId) async {
    final result = await _removeFromCart(productId);
    if (result.isRight) await _loadCart();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final result = await _updateItem(productId, quantity);
    if (result.isRight) await _loadCart();
  }

  Future<void> reload() => _loadCart();
}

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  return CartNotifier(
    sl<GetCartUseCase>(),
    sl<AddToCartUseCase>(),
    sl<RemoveFromCartUseCase>(),
    sl<UpdateCartItemUseCase>(),
  );
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).maybeWhen(
        data: (cart) => cart.itemCount,
        orElse: () => 0,
      );
});
