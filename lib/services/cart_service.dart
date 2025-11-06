import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

class CartService {
  static const String cartKey = 'cart_items';

  Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(cartKey);
      
      if (cartJson == null) return [];
      
      List<dynamic> jsonList = jsonDecode(cartJson);
      return jsonList.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  Future<void> addToCart(CartItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<CartItem> cartItems = await getCartItems();
      
      final existingIndex = cartItems.indexWhere((element) => element.id == item.id);
      
      if (existingIndex != -1) {
        cartItems[existingIndex].quantity += item.quantity;
      } else {
        cartItems.add(item);
      }
      
      List<Map<String, dynamic>> jsonList = cartItems.map((item) => item.toJson()).toList();
      await prefs.setString(cartKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<CartItem> cartItems = await getCartItems();
      
      cartItems.removeWhere((item) => item.id == productId);
      
      List<Map<String, dynamic>> jsonList = cartItems.map((item) => item.toJson()).toList();
      await prefs.setString(cartKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<CartItem> cartItems = await getCartItems();
      
      final index = cartItems.indexWhere((item) => item.id == productId);
      if (index != -1) {
        if (quantity <= 0) {
          cartItems.removeAt(index);
        } else {
          cartItems[index].quantity = quantity;
        }
      }
      
      List<Map<String, dynamic>> jsonList = cartItems.map((item) => item.toJson()).toList();
      await prefs.setString(cartKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cartKey);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  Future<int> getCartCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}
