import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../core/utils/constants.dart';

class CatalogState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;

  const CatalogState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
    this.searchQuery = '',
  });

  CatalogState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return CatalogState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final GetProductsUseCase _getProducts;
  final SearchProductsUseCase _searchProducts;

  CatalogNotifier(this._getProducts, this._searchProducts)
      : super(const CatalogState());

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true, currentPage: 0, products: []);
    final result = await _getProducts(page: 0, limit: AppConstants.pageSize);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        currentPage: 1,
        hasMore: products.length >= AppConstants.pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.searchQuery.isNotEmpty) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _getProducts(
      page: state.currentPage,
      limit: AppConstants.pageSize,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      ),
      (newProducts) => state = state.copyWith(
        isLoadingMore: false,
        products: [...state.products, ...newProducts],
        currentPage: state.currentPage + 1,
        hasMore: newProducts.length >= AppConstants.pageSize,
      ),
    );
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchQuery: '');
      await loadInitial();
      return;
    }
    state = state.copyWith(isLoading: true, searchQuery: query, clearError: true);
    final result = await _searchProducts(query);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: false,
      ),
    );
  }
}

final catalogProvider = StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier(
    sl<GetProductsUseCase>(),
    sl<SearchProductsUseCase>(),
  );
});
