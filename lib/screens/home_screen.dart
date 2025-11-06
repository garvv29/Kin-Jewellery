import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/order_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late OrderService orderService;
  Map<String, int> salesData = {};
  TextEditingController searchController = TextEditingController();
  List filteredProducts = [];

  @override
  void initState() {
    super.initState();
    orderService = OrderService();
    _loadSalesData();
  }

  void _loadSalesData() async {
    final data = await orderService.getSalesData();
    setState(() {
      salesData = data;
      // If no data, generate dummy data with 0 values
      if (salesData.isEmpty) {
        salesData = {
          'Ring': 0,
          'Bracelet': 0,
          'Necklace': 0,
          'Earring': 0,
          'Chain': 0,
        };
      }
    });
  }

  void _filterProducts(String query) {
    final productController = Get.find<ProductController>();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = productController.products;
      } else {
        filteredProducts = productController.products
            .where((product) =>
                product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'KIN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            letterSpacing: 3,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const CartScreen());
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 28,
                    ),
                    if (cartController.cartCount.value > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              cartController.cartCount.value.toString(),
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (productController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFD4AF37),
              ),
            ),
          );
        }

        if (productController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${productController.errorMessage.value}',
              textAlign: TextAlign.center,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => productController.fetchProducts(),
          color: const Color(0xFFD4AF37),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // Premium Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterProducts,
                      decoration: InputDecoration(
                        hintText: 'Search jewels...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFD4AF37),
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFFD4AF37)),
                                onPressed: () {
                                  searchController.clear();
                                  _filterProducts('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Featured Collections (Horizontal Scroll)
                if (productController.products.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Featured Collections',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: productController.products.length > 5
                              ? 5
                              : productController.products.length,
                          itemBuilder: (context, index) {
                            final product = productController.products[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: SizedBox(
                                width: 180,
                                child: ProductCard(
                                  title: product.title,
                                  image: product.image,
                                  description: product.description,
                                  price: product.price,
                                  rating: product.rating,
                                  ratingCount: product.ratingCount,
                                  onTap: () {
                                    Get.to(
                                      () => ProductDetailScreen(product: product),
                                    );
                                  },
                                  onAddToCart: () {
                                    Get.bottomSheet(
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(20),
                                        child: _buildQuantitySelector(
                                          product: product,
                                          cartController: cartController,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // All Products Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: searchController.text.isEmpty
                      ? productController.products.length
                      : filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = searchController.text.isEmpty
                        ? productController.products[index]
                        : filteredProducts[index];
                    return ProductCard(
                      title: product.title,
                      image: product.image,
                      description: product.description,
                      price: product.price,
                      rating: product.rating,
                      ratingCount: product.ratingCount,
                      onTap: () {
                        Get.to(
                          () => ProductDetailScreen(product: product),
                        );
                      },
                      onAddToCart: () {
                        Get.bottomSheet(
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(20),
                            child: _buildQuantitySelector(
                              product: product,
                              cartController: cartController,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Sales Graph at Bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales Analytics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Live',
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (salesData.isEmpty)
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('Loading chart...'),
                            ),
                          )
                        else
                          SizedBox(
                            height: 320,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceEvenly,
                                maxY: (salesData.values.isEmpty
                                        ? 10
                                        : (salesData.values.reduce((a, b) => a > b ? a : b) > 0
                                            ? salesData.values.reduce((a, b) => a > b ? a : b) * 1.4
                                            : 10))
                                    .toDouble(),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.black.withOpacity(0.8),
                                    tooltipRoundedRadius: 12,
                                    tooltipMargin: 8,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= salesData.keys.length) {
                                          return const Text('');
                                        }
                                        final title = salesData.keys.elementAt(index);
                                        // Abbreviate long titles for chart display
                                        String displayTitle = title;
                                        if (title.length > 12) {
                                          displayTitle = title.substring(0, 12);
                                        }
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Transform.rotate(
                                              angle: -0.5, // Rotate 45 degrees (approx -0.5 radians)
                                              child: Text(
                                                displayTitle,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF1A1A1A),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 70, // Increased from 45 to give more space
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 45,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.15),
                                      strokeWidth: 1,
                                    );
                                  },
                                  drawVerticalLine: false,
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                barGroups: List.generate(
                                  salesData.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: salesData.values
                                            .elementAt(index)
                                            .toDouble(),
                                        color: const Color(0xFFD4AF37),
                                        width: 20,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: (salesData.values.isEmpty
                                                  ? 10
                                                  : (salesData.values
                                                          .reduce((a, b) => a > b ? a : b) >
                                                      0
                                                  ? salesData.values.reduce(
                                                          (a, b) => a > b ? a : b) *
                                                      1.3
                                                  : 10))
                                              .toDouble(),
                                          color: Colors.grey[100],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuantitySelector({
    required product,
    required CartController cartController,
  }) {
    var quantity = 1;
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, color: Color(0xFFD4AF37)),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Add to cart WITHOUT login check - works for both logged-in and anonymous users
                    cartController.addToCart(product, quantity);
                    Get.back();
                    Get.snackbar(
                      'Success',
                      '${product.title} added to cart',
                      backgroundColor: const Color(0xFFD4AF37),
                      colorText: const Color(0xFF1A1A1A),
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
