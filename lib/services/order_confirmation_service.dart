import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OrderConfirmationService {
  static const String _ordersKey = 'orders';

  Future<String> placeOrder({
    required String paymentMethod,
    required double totalAmount,
    required List<dynamic> items,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Generate unique order ID
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create order data
      final orderData = {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        'totalAmount': totalAmount,
        'items': items,
        'status': 'confirmed',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Get existing orders
      final existingOrdersJson = prefs.getString(_ordersKey) ?? '[]';
      final existingOrders = jsonDecode(existingOrdersJson) as List;
      
      // Add new order
      existingOrders.add(orderData);
      
      // Save orders
      await prefs.setString(_ordersKey, jsonEncode(existingOrders));
      
      return orderId;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<dynamic>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey) ?? '[]';
      return jsonDecode(ordersJson) as List;
    } catch (e) {
      return [];
    }
  }

  Future<void> clearOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
    } catch (e) {
      print('Error clearing orders: $e');
    }
  }
}
