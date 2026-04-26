import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intercommerce_app/core/utils/either.dart';
import 'package:intercommerce_app/domain/repositories/cart_repository.dart';
import 'package:intercommerce_app/domain/usecases/update_cart_item_usecase.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late UpdateCartItemUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = UpdateCartItemUseCase(mockRepository);
  });

  group('UpdateCartItemUseCase', () {
    test('should call updateQuantity when quantity > 0', () async {
      when(() => mockRepository.updateQuantity(any(), any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase(1, 3);

      expect(result.isRight, true);
      verify(() => mockRepository.updateQuantity(1, 3)).called(1);
      verifyNever(() => mockRepository.removeItem(any()));
    });

    test('should call removeItem when quantity is 0', () async {
      when(() => mockRepository.removeItem(any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase(1, 0);

      expect(result.isRight, true);
      verify(() => mockRepository.removeItem(1)).called(1);
      verifyNever(() => mockRepository.updateQuantity(any(), any()));
    });

    test('should call removeItem when quantity is negative', () async {
      when(() => mockRepository.removeItem(any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase(1, -1);

      expect(result.isRight, true);
      verify(() => mockRepository.removeItem(1)).called(1);
    });
  });
}
