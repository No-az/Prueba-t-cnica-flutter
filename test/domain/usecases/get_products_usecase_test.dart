import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intercommerce_app/core/utils/either.dart';
import 'package:intercommerce_app/core/error/failures.dart';
import 'package:intercommerce_app/domain/entities/product.dart';
import 'package:intercommerce_app/domain/repositories/product_repository.dart';
import 'package:intercommerce_app/domain/usecases/get_products_usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  final tProducts = [
    const Product(
      id: 1,
      title: 'iPhone 9',
      description: 'An apple mobile',
      price: 549.99,
      discountPercentage: 12.96,
      rating: 4.69,
      stock: 94,
      brand: 'Apple',
      category: 'smartphones',
      thumbnail: 'https://example.com/thumbnail.jpg',
      images: [],
    ),
  ];

  group('GetProductsUseCase', () {
    test('should return products from repository on success', () async {
      when(() => mockRepository.getProducts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => right(tProducts));

      final result = await useCase(page: 0, limit: 10);

      expect(result.isRight, true);
      result.fold((_) => fail('Expected Right'), (products) {
        expect(products, equals(tProducts));
        expect(products.length, 1);
      });

      verify(() => mockRepository.getProducts(page: 0, limit: 10)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when repository fails', () async {
      when(() => mockRepository.getProducts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => left(const Failure.network(message: 'No connection')));

      final result = await useCase(page: 0, limit: 10);

      expect(result.isLeft, true);
      result.fold(
        (failure) => expect(
          failure,
          equals(const Failure.network(message: 'No connection')),
        ),
        (_) => fail('Expected Left'),
      );
    });

    test('should return empty list when no products are found', () async {
      when(() => mockRepository.getProducts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => right([]));

      final result = await useCase(page: 0, limit: 10);

      expect(result.isRight, true);
      result.fold((_) => fail('Expected Right'), (products) {
        expect(products, isEmpty);
      });
    });

    test('should call repository with correct pagination params', () async {
      when(() => mockRepository.getProducts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => right(tProducts));

      await useCase(page: 2, limit: 10);

      verify(() => mockRepository.getProducts(page: 2, limit: 10)).called(1);
    });
  });
}
