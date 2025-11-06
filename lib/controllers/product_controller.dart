import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService productService = ProductService();
  
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final productList = await productService.fetchProducts();
      products.value = productList;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Product? getProductById(int id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
