class NotificationItem {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? linkUrl;
  final String type; // e.g., 'broadcast'
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.linkUrl,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      type: json['type'] as String? ?? 'broadcast',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class NotificationMeta {
  final int total;
  final int page;
  final int lastPage;

  NotificationMeta({
    required this.total,
    required this.page,
    required this.lastPage,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }
}

class StudentNotificationsResponse {
  final bool success;
  final String message;
  final List<NotificationItem> data;
  final NotificationMeta meta;

  StudentNotificationsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory StudentNotificationsResponse.fromJson(Map<String, dynamic> json) {
    final dataObj = json['data'] as Map<String, dynamic>;
    final list = (dataObj['data'] as List<dynamic>)
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = NotificationMeta.fromJson(dataObj['meta'] as Map<String, dynamic>);

    return StudentNotificationsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: list,
      meta: meta,
    );
  }
}
