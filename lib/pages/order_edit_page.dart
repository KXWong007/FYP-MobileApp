// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/order_service.dart';

// class OrderEditPage extends StatefulWidget {
//   final String orderId;

//   const OrderEditPage({required this.orderId});

//   @override
//   _OrderEditPageState createState() => _OrderEditPageState();
// }

// class _OrderEditPageState extends State<OrderEditPage> {
//   final TextEditingController _tableNumController = TextEditingController();
//   List<Map<String, dynamic>> _orderItems = [];

//   // Filtered list for display
//   List<Map<String, dynamic>> get _visibleOrderItems {
//     return _orderItems.where((item) => item['status'] != 'Cancelled').toList();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadOrderDetails();
//   }

//   Future<void> _loadOrderDetails() async {
//     final orderService = Provider.of<OrderService>(context, listen: false);
//     await orderService.fetchOrderDetails(widget.orderId);

//     setState(() {
//       _tableNumController.text =
//           orderService.selectedOrder['tableNum']?.toString() ?? '';
//       _orderItems = List<Map<String, dynamic>>.from(
//           orderService.selectedOrder['orderItems'] ?? []);
//     });
//   }

//   @override
//   void dispose() {
//     _tableNumController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveOrder() async {
//     final newTableNum = _tableNumController.text.trim();
//     if (newTableNum.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Table number cannot be empty')),
//       );
//       return;
//     }

//     try {
//       final orderService = Provider.of<OrderService>(context, listen: false);

//       // Send updated data to the backend
//       await orderService.editOrder(
//         widget.orderId,
//         newTableNum,
//         _orderItems, // Save all items, including cancelled ones
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order updated successfully')),
//       );
//       Navigator.pop(context);
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update order: $error')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Edit Order')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _tableNumController,
//               decoration: InputDecoration(
//                 labelText: 'Table Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: _visibleOrderItems.isEmpty
//                   ? Center(child: Text('No order items available.'))
//                   : ListView.builder(
//                       itemCount: _visibleOrderItems.length,
//                       itemBuilder: (context, index) {
//                         final item = _visibleOrderItems[index];
//                         return Card(
//                           margin: EdgeInsets.symmetric(vertical: 8.0),
//                           child: Column(
//                             children: [
//                               ListTile(
//                                 title: Text(item['dishName'] ?? 'Unknown Dish'),
//                                 subtitle: Text('Quantity: ${item['quantity']}'),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _saveOrder,
//               child: Text('Save Changes'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
