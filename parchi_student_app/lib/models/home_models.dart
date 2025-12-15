// lib/models/home_models.dart

class Brand {
  final String name;
  final String time;
  final String image;

  Brand({required this.name, required this.time, required this.image});
}

class Restaurant {
  final String name;
  final String image;
  final String rating;
  final String meta;
  final String discount;

  Restaurant({
    required this.name,
    required this.image,
    required this.rating,
    required this.meta,
    required this.discount,
  });
}