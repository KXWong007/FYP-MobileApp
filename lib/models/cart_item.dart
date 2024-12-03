class CartItem {
  final String dishName;
  final double price;
  int quantity;
  String remarks;
  final String dishId;

  CartItem({
    required this.dishName,
    required this.price,
    this.quantity = 1,
    this.remarks = '',
    required this.dishId,
  });

  // Optionally, you can add a method to convert the CartItem to a map for API submission
  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'quantity': quantity,
      'remark': remarks,
    };
  }
}
