class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating']?['rate'] ?? 0).toDouble(),
      ratingCount: json['rating']?['count'] ?? 0,
    );
  }
}
