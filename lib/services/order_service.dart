import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderService {
  static const String ordersKey = 'orders';

  Future<List<Order>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(ordersKey);
      
      if (ordersJson == null) return [];
      
      List<dynamic> jsonList = jsonDecode(ordersJson);
      return jsonList.map((item) => Order.fromJson(item)).toList();
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  Future<void> saveOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Order> orders = await getOrders();
      orders.add(order);
      
      List<Map<String, dynamic>> jsonList = orders.map((order) => order.toJson()).toList();
      await prefs.setString(ordersKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  Future<Map<String, int>> getSalesData() async {
    try {
      final orders = await getOrders();
      Map<String, int> salesData = {};
      
      for (var order in orders) {
        for (var item in order.items) {
          String title = item['title'] ?? 'Unknown';
          int quantity = item['quantity'] ?? 1;
          
          if (salesData.containsKey(title)) {
            salesData[title] = salesData[title]! + quantity;
          } else {
            salesData[title] = quantity;
          }
        }
      }
      
      return salesData;
    } catch (e) {
      print('Error getting sales data: $e');
      return {};
    }
  }
}
