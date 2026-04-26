import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';

final productDetailProvider =
    FutureProvider.family<Product, int>((ref, id) async {
  final useCase = sl<GetProductDetailUseCase>();
  final result = await useCase(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});
