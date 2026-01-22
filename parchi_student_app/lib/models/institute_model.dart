class Institute {
  final String id;
  final String name;

  Institute({
    required this.id,
    required this.name,
  });

  factory Institute.fromJson(Map<String, dynamic> json) {
    return Institute(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
