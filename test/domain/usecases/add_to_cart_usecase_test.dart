import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intercommerce_app/core/utils/either.dart';
import 'package:intercommerce_app/core/error/failures.dart';
import 'package:intercommerce_app/domain/entities/product.dart';
import 'package:intercommerce_app/domain/repositories/cart_repository.dart';
import 'package:intercommerce_app/domain/usecases/add_to_cart_usecase.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late AddToCartUseCase useCase;
  late MockCartRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const Product(
      id: 1,
      title: 'Test',
      description: '',
      price: 10.0,
      discountPercentage: 0,
      rating: 0,
      stock: 10,
      brand: '',
      category: '',
      thumbnail: '',
      images: [],
    ));
  });

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = AddToCartUseCase(mockRepository);
  });

  const tProduct = Product(
    id: 1,
    title: 'Test Product',
    description: 'Test',
    price: 29.99,
    discountPercentage: 0,
    rating: 4.5,
    stock: 50,
    brand: 'Brand',
    category: 'cat',
    thumbnail: 'https://example.com/img.jpg',
    images: [],
  );

  group('AddToCartUseCase', () {
    test('should add product to cart with default quantity 1', () async {
      when(() => mockRepository.addItem(any(), any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase(tProduct);

      expect(result.isRight, true);
      verify(() => mockRepository.addItem(tProduct, 1)).called(1);
    });

    test('should add product with custom quantity', () async {
      when(() => mockRepository.addItem(any(), any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase(tProduct, quantity: 3);

      expect(result.isRight, true);
      verify(() => mockRepository.addItem(tProduct, 3)).called(1);
    });

    test('should return CacheFailure when repository fails', () async {
      when(() => mockRepository.addItem(any(), any()))
          .thenAnswer((_) async => left(const Failure.cache(message: 'DB error')));

      final result = await useCase(tProduct);

      expect(result.isLeft, true);
    });
  });
}
