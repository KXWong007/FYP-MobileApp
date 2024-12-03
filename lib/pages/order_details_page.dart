import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId; // Pass orderId to fetch specific order details

  OrderDetailsPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffe6be8a),
        title: Text('Order Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Provider.of<OrderService>(context, listen: false)
              .fetchOrderDetails(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load order details: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return Consumer<OrderService>(
              builder: (context, orderService, child) {
                final order = orderService.selectedOrder;
                if (order.isEmpty) {
                  return const Center(
                      child: Text('No order details available.'));
                }

                final orderItems = order['orderItems'] ?? [];
                if (orderItems.isEmpty) {
                  return const Center(child: Text('No order items available.'));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          final dishName = item['dishName'] ?? 'Unknown';
                          final quantity = item['quantity'] ?? 0;
                          final price = double.parse(item['price'] ?? '0.0');
                          final totalPrice = quantity * price;
                          final status = item['orderItemStatus'] ?? 'Unknown';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(dishName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Qty: $quantity x RM${price.toStringAsFixed(2)}'),
                                  Text('Status: $status'),
                                ],
                              ),
                              trailing: Text(
                                'RM${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'RM${order['totalAmount']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
