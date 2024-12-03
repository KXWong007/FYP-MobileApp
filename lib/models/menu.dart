class Menu {
  final String dishId;
  final String dishName;
  final String category;
  final String subcategory;
  final String cuisine;
  final double price;
  final bool availability;
  final String? image;
  final String? description;
  final List<String> availableAreas;

  // Constructor to initialize Menu object
  Menu({
    required this.dishId,
    required this.dishName,
    required this.category,
    required this.subcategory,
    required this.cuisine,
    required this.price,
    required this.availability,
    this.image,
    this.description,
    required this.availableAreas,
  });

  // Factory constructor to create a Menu object from JSON
  factory Menu.fromJson(Map<String, dynamic> json) {
    // Helper function to parse available areas
    List<String> parseAvailableAreas(dynamic availableArea) {
      if (availableArea == null) return [];
      if (availableArea is List) {
        return availableArea.map((e) => e.toString()).toList();
      }
      if (availableArea is String) {
        return availableArea.split(',').map((e) => e.trim()).toList();
      }
      return [];
    }

    return Menu(
      dishId: json['dishId'] ?? '',
      dishName: json['dishName'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      cuisine: json['cuisine'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      availability: json['availability'],
      image: json['image'],
      description: json['description'],
      availableAreas: parseAvailableAreas(json['availableArea']),
    );
  }

  // Getter to return the availability status as a string
  String get availabilityStatus {
    return availability ? 'Available' : 'Unavailable';
  }
}
