import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'package:http/http.dart' as http;
import 'orders_page.dart';

class CartPage extends StatefulWidget {
  final String tableNum;
  final String customerId;

  CartPage({required this.tableNum, required this.customerId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isCheckoutVisible = false;

  // Method to generate the orderId in ymdhisv format
  String generateOrderId() {
    final now = DateTime.now();
    final microseconds = (now.microsecondsSinceEpoch % 1000000) ~/
        10000; // Get microseconds as 2 digits

    final orderId =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}$microseconds';

    return orderId;
  }

  // Method to handle checkout
  Future<void> proceedToCheckout() async {
    final cartService = Provider.of<CartService>(context, listen: false);

    // Check if cart is empty before proceeding
    if (cartService.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    // Generate order ID synchronously before continuing
    final orderId = generateOrderId();
    final orderDate = DateTime.now().toIso8601String(); // Use current date
    final customerId = widget.customerId;
    final tableNum = widget.tableNum;
    final totalAmount = cartService.totalPrice;

    // Prepare order items
    List<Map<String, dynamic>> orderItems =
        cartService.cartItems.map((cartItem) {
      return {
        'dishId': cartItem.dishId,
        'quantity': cartItem.quantity,
        'remark': cartItem.remarks, // Can be null if no remark
      };
    }).toList();

    // Prepare request body
    final requestBody = {
      'orderId': orderId,
      'customerId': customerId,
      'tableNum': tableNum,
      'orderDate': orderDate,
      'totalAmount': totalAmount,
      'status': 'Pending',
      'orderItems': orderItems,
    };

    try {
      // Send request to the backend
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order placed successfully!')));

        // Show success dialog with option to check order status
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Order Created'),
              content: Text('Your order has been successfully placed.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderPage()),
                    );
                  },
                  child: Text('Check Order Status'),
                ),
              ],
            );
          },
        );

        cartService.clearCart(); // Clear the cart after successful order
      } else {
        // Handle failure
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to place order')));
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Your Cart'),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;

        return Consumer<CartService>(
          builder: (context, cartService, child) {
            if (cartService.cartItems.isEmpty) {
              return const Center(child: Text('Your cart is empty.'));
            }

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: maxWidth,
                      child: ListView.builder(
                        itemCount: cartService.cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartService.cartItems[index];

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(cartItem.dishName),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (cartItem.remarks.isNotEmpty)
                                    Text(
                                      '${cartItem.remarks}',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                  Text('RM ${cartItem.price.toStringAsFixed(2)}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (cartItem.quantity > 1) {
                                            cartService.updateQuantity(
                                                cartItem, cartItem.quantity - 1);
                                          }
                                        },
                                      ),
                                      Text(cartItem.quantity.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          cartService.updateQuantity(
                                              cartItem, cartItem.quantity + 1);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  cartService.removeFromCart(cartItem);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: maxWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: RM ${cartService.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isCheckoutVisible =
                                  !isCheckoutVisible; // Toggle checkout visibility
                            });
                          },
                          child: const Text('Proceed to Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isCheckoutVisible) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checkout Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: cartService.cartItems.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartService.cartItems[index];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${cartItem.dishName} x${cartItem.quantity}'),
                                  Text('RM ${cartItem.price * cartItem.quantity}'),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Total: RM ${cartService.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: proceedToCheckout,
                                child: const Text('Checkout'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    ),
  );
}

}
