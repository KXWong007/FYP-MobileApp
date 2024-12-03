import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/order_service.dart';
import 'order_details_page.dart'; // Assume you have this page to show order details

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String currentFilter = 'Pending'; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Top Banner with Title and Back Button
              Stack(
                children: [
                  Container(
                    height: 60,
                    color: Color(0xffe6be8a),
                    alignment: Alignment.center,
                    child: Text(
                      'Orders List',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Navigate back to Main Menu
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20), // Space between widgets

              // Navigation Buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavigationButton(
                        context, 'Pending', Colors.blue, 'Pending'),
                    _buildNavigationButton(
                        context, 'Completed', Colors.green, 'Completed'),
                    _buildNavigationButton(
                        context, 'Cancelled', Colors.red, 'Cancelled'),
                  ],
                ),
              ),

              SizedBox(height: 20), // Space between widgets

              // Fetch orders and display them
              Expanded(
                child: FutureBuilder(
                  future: Provider.of<OrderService>(context, listen: false)
                      .fetchOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load orders: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return Consumer<OrderService>(
                      builder: (context, orderService, child) {
                        final orders = _getFilteredOrders(
                            List<Map<String, dynamic>>.from(
                                orderService.orders));

                        // Sort orders from latest to oldest
                        orders.sort((a, b) {
                          final aDate = DateTime.parse(a['orderDate']);
                          final bDate = DateTime.parse(b['orderDate']);
                          return bDate.compareTo(aDate); // Descending order
                        });

                        if (orders.isEmpty) {
                          return const Center(
                            child: Text('No orders available.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 4,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order ID
                                    Text(
                                      'Order #${order['orderId'] ?? ''}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    SizedBox(
                                        height: 8.0), // Space between fields

                                    // Table and Area
                                    Text(
                                      'Table: ${order['tableNum'] ?? ''} | Area: ${order['area'] ?? ''}',
                                      style: TextStyle(fontSize: 14),
                                    ),

                                    SizedBox(
                                        height: 8.0), // Space between fields

                                    // Date and Time
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(order['orderDate']))}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          'Time: ${DateFormat('HH:mm').format(DateTime.parse(order['orderDate']))}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                        height: 8.0), // Space between fields

                                    // Total Amount
                                    Text(
                                      'Total: RM ${order['totalAmount'] ?? '0.00'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),

                                    SizedBox(
                                        height: 8.0), // Space between fields

                                    // Order Status
                                    Text(
                                      'Status: ${order['orderStatus'] ?? 'Pending'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: order['orderStatus'] == 'Pending'
                                            ? Colors.blue
                                            : order['orderStatus'] ==
                                                    'Completed'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),

                                    SizedBox(
                                        height: 16.0), // Space before button

                                    // Buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children:
                                          _buildActionButtons(context, order),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Filter orders based on the selected status
  List<Map<String, dynamic>> _getFilteredOrders(
      List<Map<String, dynamic>> orders) {
    return orders.where((order) {
      final status = order['orderStatus'].toString().toLowerCase();
      final filter =
          currentFilter.toLowerCase(); // Convert currentFilter to lowercase
      switch (filter) {
        case 'pending':
          return status == 'pending';
        case 'completed':
          return status == 'completed';
        case 'cancelled':
          return status == 'cancelled';
        default:
          return true; // This ensures that when the filter is "All", it shows all orders
      }
    }).toList();
  }

  // Build the navigation buttons for filtering orders
  Widget _buildNavigationButton(
      BuildContext context, String label, Color color, String filter) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentFilter = filter;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            currentFilter == filter ? color : color.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _editOrder(BuildContext context, Map<String, dynamic> order) {
    TextEditingController tableController = TextEditingController();
    tableController.text =
        order['tableNum']; // Pre-fill the current table number

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Table'),
          content: TextField(
            controller: tableController,
            decoration: InputDecoration(
              labelText: 'New Table Number',
              hintText: 'Enter new table number',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without changes
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newTableNum =
                    tableController.text.trim(); // Get the new table number

                // Validate the table number by calling the API service
                bool isValid =
                    await ApiService.validateTableNumber(newTableNum);

                if (isValid) {
                  // Update the table number in the backend
                  await Provider.of<OrderService>(context, listen: false)
                      .updateOrderTableNumber(
                          order['orderId'].toString(), newTableNum);

                  // Close the dialog and refresh the UI after updating
                  Navigator.pop(context); // Close the dialog
                  setState(() {}); // Refresh the UI
                } else {
                  // Show an error message if the table number is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid table number')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _cancelOrder(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Update the order status to 'cancelled' and send it to the backend
                await Provider.of<OrderService>(context, listen: false)
                    .cancelOrder(order['orderId'].toString());

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildActionButtons(
      BuildContext context, Map<String, dynamic> order) {
    final orderDate = DateTime.parse(order['orderDate']);
    final currentTime = DateTime.now();

    // Check if the order is within 5 minutes
    final isWithinFiveMinutes =
        currentTime.difference(orderDate).inSeconds <= 300;

    // Always show the Details button
    List<Widget> buttons = [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsPage(orderId: order['orderId'].toString()),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffe6be8a),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Details',
            style: TextStyle(fontSize: 14, color: Colors.black)),
      ),
    ];

    // Show Change Table button for pending orders
    if (order['orderStatus'] == 'Pending') {
      buttons.add(
        ElevatedButton(
          onPressed: () => _editOrder(context, order),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Change Table',
              style: TextStyle(fontSize: 14, color: Colors.white)),
        ),
      );

      // Only add Delete button if order is within 5 minutes
      if (isWithinFiveMinutes) {
        buttons.add(
          ElevatedButton(
            onPressed: () => _cancelOrder(context, order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        );
      }
    }

    return buttons;
  }
}
