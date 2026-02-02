class StudentMerchantModel {
  final String id;
  final String businessName;
  final String? bannerUrl;
  final String? category;
  final int totalRedemptions;

  StudentMerchantModel({
    required this.id,
    required this.businessName,
    this.bannerUrl,
    this.category,
    required this.totalRedemptions,
  });

  factory StudentMerchantModel.fromJson(Map<String, dynamic> json) {
    return StudentMerchantModel(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? 'Unknown Merchant',
      bannerUrl: json['bannerUrl'],
      category: json['category'],
      totalRedemptions: json['totalRedemptions'] ?? 0,
    );
  }
}

class MerchantPagination {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  MerchantPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory MerchantPagination.fromJson(Map<String, dynamic> json) {
    return MerchantPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class MerchantListResponse {
  final List<StudentMerchantModel> items;
  final MerchantPagination pagination;

  MerchantListResponse({
    required this.items,
    required this.pagination,
  });

  factory MerchantListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemsList = data['items'] as List<dynamic>;

    return MerchantListResponse(
      items: itemsList
          .map((item) =>
              StudentMerchantModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: MerchantPagination.fromJson(
        data['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}
