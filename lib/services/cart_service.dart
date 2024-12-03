import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartService with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    // Check if the item already exists in the cart, and if so, increase the quantity
    final existingItem = _cartItems.firstWhere(
      (cartItem) => cartItem.dishName == item.dishName,
      orElse: () => CartItem(dishId: "", dishName: "", price: 0),
    );
    if (existingItem.dishName.isEmpty) {
      _cartItems.add(item); // Add new item to the cart
    } else {
      existingItem.quantity +=
          item.quantity; // Increase quantity of existing item
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    item.quantity = newQuantity;
    notifyListeners();
  }

  // Method to clear the cart
  void clearCart() {
    _cartItems.clear(); // Clear all items in the cart
    notifyListeners();
  }

  double get totalPrice {
    return _cartItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity));
  }
}
