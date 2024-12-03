import 'package:flutter/material.dart';
import '../models/menu.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Menu menu;

  const ProductDetailPage({Key? key, required this.menu}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  String remarks = '';

  @override
  Widget build(BuildContext context) {
    // Handle Out of Stock scenario (for availability)
    bool isAvailable = widget.menu.availability == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menu.dishName,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: double.infinity, // Makes the container full width
                height: MediaQuery.of(context)
                    .size
                    .width, // Ensures square shape by matching height with width
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.menu.image == null || widget.menu.image!.isEmpty
                    ? const Icon(
                        Icons.fastfood,
                        size: 100,
                        color: Colors.grey,
                      )
                    : Image.network(
                        // Modify the image URL to replace 'menu-images/' with 'img/menu-images/'
                        widget.menu.image!.replaceFirst(
                            'menu-images/', '../img/menu-images/'),
                        fit: BoxFit
                            .cover, // Ensures the image covers the whole container area
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons
                                .error_outline), // Error icon if image fails
                      ),
              ),

              const SizedBox(height: 16),

              // Name and Description
              Text(
                widget.menu.dishName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.menu.description ?? 'No description available',
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 16),

              // Category, Subcategory, Cuisine
              Text(
                'Category: ${widget.menu.category}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              Text(
                'Subcategory: ${widget.menu.subcategory}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              Text(
                'Cuisine: ${widget.menu.cuisine}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              Text(
                'Availability: ${widget.menu.availabilityStatus}',
                style: TextStyle(color: Colors.grey[800]),
              ),

              const SizedBox(height: 16),

              // Price
              Text(
                'Price: RM${widget.menu.price.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Quantity Selector
              Row(
                children: [
                  const Text('Quantity:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        setState(() => quantity++), // Remove limit on max stock
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Remark Input
              TextField(
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDEB887)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    remarks = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAvailable
                      ? () {
                          // Create a CartItem object
                          final cartItem = CartItem(
                            dishId: widget.menu.dishId,
                            dishName: widget.menu.dishName,
                            price: widget.menu.price,
                            quantity: quantity,
                            remarks: remarks,
                          );

                          // Add the item to the cart using CartService
                          Provider.of<CartService>(context, listen: false)
                              .addToCart(cartItem);

                          // Optionally, show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${widget.menu.dishName} added to cart')),
                          );

                          // Optionally, navigate back to the previous page
                          Navigator.pop(context);
                        }
                      : null, // Disable the button if not available
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable
                        ? const Color(0xFFDEB887) // Regular color if available
                        : Colors.grey, // Grey color if unavailable
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isAvailable
                        ? 'Add to Cart'
                        : 'Out of Stock', // Display text accordingly
                    style: TextStyle(
                      color: isAvailable ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
