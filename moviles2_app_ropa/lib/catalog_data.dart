// catalog_data.dart

class CatalogItem {
  final String name;
  final String imageUrl;
  final double price;
  final String brand;
  final String description;
  final bool isOnSale;
  final int discountPercent;
  final double rating;
  final int reviewCount;

  CatalogItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.brand,
    required this.description,
    this.isOnSale = false,
    this.discountPercent = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
  });
}

class CatalogData {
  static final List<CatalogItem> items = [
    CatalogItem(
      name: 'Casaca Jean',
      imageUrl: './images/casacajean.png',
      price: 89.90,
      brand: 'DenimCo',
      description:
          'Chaqueta de mezclilla con botones metálicos y bolsillos frontales.',
      isOnSale: true,
      discountPercent: 15,
      rating: 4.2,
      reviewCount: 34,
    ),
    CatalogItem(
      name: 'Polo Oversize',
      imageUrl: './images/polo.png',
      price: 59.90,
      brand: 'UrbanFit',
      description: 'Camiseta holgada de algodón peinado, diseño moderno.',
      rating: 4.8,
      reviewCount: 58,
    ),
  ];
}
