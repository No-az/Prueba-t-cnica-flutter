import '../../core/utils/constants.dart' show AppConstants;
import 'cart_item.dart';

class Cart {
  final List<CartItem> items;

  const Cart({required this.items});

  static const Cart empty = Cart(items: []);

  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);
  double get tax => subtotal * AppConstants.taxRate;
  double get total => subtotal + tax;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Cart copyWith({List<CartItem>? items}) => Cart(items: items ?? this.items);
}
