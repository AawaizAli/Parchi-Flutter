import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merchant_detail_model.dart';
import '../models/student_merchant_model.dart';
import '../services/merchants_service.dart';

// Provider for fetching merchant details by ID
final merchantDetailsProvider = FutureProvider.family<MerchantDetailModel, String>(
  (ref, merchantId) async {
    return merchantsService.getMerchantDetails(merchantId);
  },
);

// State class for Merchant List
class MerchantListState {
  final List<StudentMerchantModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;
  final String searchQuery; // [NEW]

  MerchantListState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.searchQuery = "", // [NEW]
  });

  MerchantListState copyWith({
    List<StudentMerchantModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    bool? hasMore,
    String? searchQuery, // [NEW]
  }) {
    return MerchantListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error, // Keep error nullable update if passed explicitly? defaulting to keep old is better usually unless clearing.
      // Actually my previous implementation of copyWith for error was a bit loose.
      // Let's stick to standard pattern: if passed, update.
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery, // [NEW]
    );
  }
}

// Notifier to manage the merchant list state
class MerchantListNotifier extends StateNotifier<MerchantListState> {
  final MerchantsService _service;
  final int _limit = 10;

  MerchantListNotifier(this._service) : super(MerchantListState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final now = DateTime.now();
      final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final response = await _service.getStudentMerchants(
        page: 1,
        limit: _limit,
        month: currentMonth,
        search: state.searchQuery, // [NEW]
      );

      state = state.copyWith(
        items: response.items,
        isLoading: false,
        page: 1,
        hasMore: response.pagination.hasNext,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    // Keep search query, reset list
    state = state.copyWith(items: [], isLoading: true, page: 1, hasMore: true);
    await loadInitial();
  }

  Future<void> search(String query) async {
    // Update query, reset list, load
    if (state.searchQuery == query) return; // Debounce duplicate
    
    state = state.copyWith(
      searchQuery: query,
      items: [], 
      isLoading: true, 
      page: 1, 
      hasMore: true
    );
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    try {
      state = state.copyWith(isLoadingMore: true);
      final nextPage = state.page + 1;
      
      final now = DateTime.now();
      final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final response = await _service.getStudentMerchants(
        page: nextPage,
        limit: _limit,
        month: currentMonth,
        search: state.searchQuery, // [NEW]
      );

      state = state.copyWith(
        items: [...state.items, ...response.items],
        isLoadingMore: false,
        page: nextPage,
        hasMore: response.pagination.hasNext,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final studentMerchantsProvider =
    StateNotifierProvider<MerchantListNotifier, MerchantListState>((ref) {
  return MerchantListNotifier(merchantsService);
});

