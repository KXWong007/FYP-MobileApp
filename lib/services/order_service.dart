import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OrderService with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic> _selectedOrder = {};

  List<Map<String, dynamic>> get orders => _orders;

  Map<String, dynamic> get selectedOrder => _selectedOrder;

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customer/order'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        _orders = List<Map<String, dynamic>>.from(json.decode(response.body));
        notifyListeners();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      throw Exception('Error fetching orders: $error');
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customer/order/$orderId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        _selectedOrder = json.decode(response.body);
        _selectedOrder['orderItems'] ??= [];
        notifyListeners();
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (error) {
      throw Exception('Error fetching order details: $error');
    }
  }

  Future<void> updateOrderTableNumber(
      String orderId, String newTableNum) async {
    final url =
        'http://127.0.0.1:8000/api/customer/order/edit/$orderId'; // Your backend API endpoint

    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode({
          'tableNum': newTableNum, // Pass the new table number
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_TOKEN', // Provide authorization token if needed
        },
      );

      if (response.statusCode == 200) {
        await fetchOrders();
        print('Table number updated successfully!');
      } else {
        throw Exception('Failed to update table number');
      }
    } catch (error) {
      print('Error: $error');
      throw error;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/customer/order/cancel/$orderId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchOrders();
      } else {
        throw Exception('Failed to cancel order');
      }
    } catch (error) {
      throw Exception('Error canceling order: $error');
    }
  }
}
