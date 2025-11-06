import 'package:get/get.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../models/product_model.dart';

class CartController extends GetxController {
  final CartService cartService = CartService();
  
  var cartItems = <CartItem>[].obs;
  var cartTotal = 0.0.obs;
  var cartCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    final items = await cartService.getCartItems();
    cartItems.value = items;
    await updateCartTotals();
  }

  Future<void> addToCart(Product product, int quantity) async {
    final cartItem = CartItem(
      id: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      quantity: quantity,
    );
    
    await cartService.addToCart(cartItem);
    await loadCart();
  }

  Future<void> removeFromCart(int productId) async {
    await cartService.removeFromCart(productId);
    await loadCart();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    await cartService.updateQuantity(productId, quantity);
    await loadCart();
  }

  Future<void> updateCartTotals() async {
    final total = await cartService.getCartTotal();
    final count = await cartService.getCartCount();
    
    cartTotal.value = total;
    cartCount.value = count;
  }

  Future<void> clearCart() async {
    await cartService.clearCart();
    await loadCart();
  }

  double get subtotal => cartTotal.value;
  double get taxes => subtotal * 0.08; // 8% tax
  double get total => subtotal + taxes;
}
