import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intercommerce_app/core/utils/either.dart';
import 'package:intercommerce_app/core/error/failures.dart';
import 'package:intercommerce_app/domain/entities/product.dart';
import 'package:intercommerce_app/domain/usecases/get_products_usecase.dart';
import 'package:intercommerce_app/domain/usecases/search_products_usecase.dart';
import 'package:intercommerce_app/presentation/providers/catalog_provider.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProducts;
  late MockSearchProductsUseCase mockSearchProducts;

  setUp(() {
    mockGetProducts = MockGetProductsUseCase();
    mockSearchProducts = MockSearchProductsUseCase();
  });

  CatalogNotifier buildNotifier() =>
      CatalogNotifier(mockGetProducts, mockSearchProducts);

  final tProducts = List.generate(
    10,
    (i) => Product(
      id: i + 1,
      title: 'Product $i',
      description: '',
      price: 10.0 * (i + 1),
      discountPercentage: 0,
      rating: 4.0,
      stock: 10,
      brand: 'Brand',
      category: 'cat',
      thumbnail: '',
      images: const [],
    ),
  );

  group('CatalogNotifier', () {
    test('initial state is empty with no loading', () {
      final notifier = buildNotifier();
      expect(notifier.state.products, isEmpty);
      expect(notifier.state.isLoading, false);
    });

    test('loadInitial sets isLoading then populates products', () async {
      when(() => mockGetProducts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => right(tProducts));

      final notifier = buildNotifier();
      await notifier.loadInitial();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.products.length, 10);
      expect(notifier.state.hasMore, true);
      expect(notifier.state.currentPage, 1);
    });

    test('loadInitial sets error state on failure', () async {
      when(() => mockGetProducts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => left(const Failure.network(message: 'No connection')));

      final notifier = buildNotifier();
      await notifier.loadInitial();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'No connection');
      expect(notifier.state.products, isEmpty);
    });

    test('loadMore appends products and increments page', () async {
      when(() => mockGetProducts(page: 0, limit: any(named: 'limit')))
          .thenAnswer((_) async => right(tProducts));
      when(() => mockGetProducts(page: 1, limit: any(named: 'limit')))
          .thenAnswer((_) async => right(tProducts.sublist(0, 5)));

      final notifier = buildNotifier();
      await notifier.loadInitial();
      await notifier.loadMore();

      expect(notifier.state.products.length, 15);
      expect(notifier.state.hasMore, false);
    });

    test('search replaces products list', () async {
      when(() => mockSearchProducts(any()))
          .thenAnswer((_) async => right(tProducts.sublist(0, 3)));

      final notifier = buildNotifier();
      await notifier.search('phone');

      expect(notifier.state.products.length, 3);
      expect(notifier.state.searchQuery, 'phone');
      expect(notifier.state.hasMore, false);
    });
  });
}
