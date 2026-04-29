import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: Text(
          'Kin',
          style: GoogleFonts.bodoniModa(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
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

                // Premium Promotional Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2D2D2D),
                        ],
                      ),
                      boxShadow: [],
                    ),
                    child: Stack(
                      children: [
                        // Background overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Left Content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top: Discount and Date
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Up to ',
                                        style: GoogleFonts.bodoniModa(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFD4AF37),
                                              const Color(0xFFFBD89B),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '40% Off',
                                          style: GoogleFonts.bodoniModa(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1A1A1A),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Oct 28 - Nov 28',
                                    style: GoogleFonts.bodoniModa(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFFD4AF37),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              // Bottom: Offer Text and Button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Get Special Offer',
                                    style: GoogleFonts.bodoniModa(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar(
                                        'Special Offer',
                                        'Exclusive deals loading...',
                                        backgroundColor: const Color(0xFFD4AF37),
                                        colorText: const Color(0xFF1A1A1A),
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFD4AF37),
                                            const Color(0xFFFBD89B),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFD4AF37).withOpacity(0.4),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Shop Now',
                                        style: GoogleFonts.bodoniModa(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1A1A),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right: Premium Image Placeholder
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                            child: Container(
                              width: 160,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFD4AF37).withOpacity(0.2),
                                    const Color(0xFF1A1A1A).withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Decorative pattern
                                  Positioned(
                                    top: -20,
                                    right: -20,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(0xFFD4AF37).withOpacity(0.15),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Placeholder for image - you can replace with actual image
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.diamond,
                                        size: 48,
                                        color: const Color(0xFFD4AF37).withOpacity(0.8),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Premium\nCollection',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                            Text(
                              'Featured Collections',
                              style: GoogleFonts.bodoniModa(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
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
                      Text(
                        'All Products',
                        style: GoogleFonts.bodoniModa(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFFFAFAFA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4AF37),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sales Analytics',
                                      style: GoogleFonts.bodoniModa(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Color(0xFFD4AF37),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Live',
                                    style: TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        
                        // Charts Container
                        if (salesData.isEmpty)
                          Container(
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('Loading analytics...'),
                            ),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Bar Chart
                                SizedBox(
                                  width: 320,
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
                                          tooltipBgColor: const Color(0xFF1A1A1A),
                                          tooltipRoundedRadius: 12,
                                          tooltipMargin: 8,
                                          tooltipBorder: BorderSide(
                                            color: const Color(0xFFD4AF37),
                                            width: 1,
                                          ),
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
                                              String displayTitle = title.length > 8 
                                                  ? title.substring(0, 8) 
                                                  : title;
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 12),
                                                  child: Text(
                                                    displayTitle,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF666666),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              );
                                            },
                                            reservedSize: 50,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${value.toInt()}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFFB0B0B0),
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
                                            color: const Color(0xFFD4AF37).withOpacity(0.08),
                                            strokeWidth: 1,
                                          );
                                        },
                                        drawVerticalLine: false,
                                      ),
                                      borderData: FlBorderData(show: false),
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
                                              width: 18,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              backDrawRodData: BackgroundBarChartRodData(
                                                show: true,
                                                toY: (salesData.values.isEmpty
                                                        ? 10
                                                        : (salesData.values.reduce(
                                                                (a, b) => a > b ? a : b) >
                                                            0
                                                        ? salesData.values.reduce(
                                                                (a, b) => a > b ? a : b) *
                                                            1.3
                                                        : 10))
                                                    .toDouble(),
                                                color: const Color(0xFFD4AF37).withOpacity(0.08),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                
                                // Pie Chart
                                SizedBox(
                                  width: 280,
                                  height: 280,
                                  child: PieChart(
                                    PieChartData(
                                      sections: List.generate(
                                        salesData.length,
                                        (index) {
                                          final total = salesData.values.reduce((a, b) => a + b);
                                          final value = salesData.values.elementAt(index).toDouble();
                                          final percentage = (value / (total > 0 ? total : 1)) * 100;
                                          
                                          final colors = [
                                            const Color(0xFFD4AF37),
                                            const Color(0xFFFBD89B),
                                            const Color(0xFFC9A227),
                                            const Color(0xFFE6C954),
                                            const Color(0xFFB8922A),
                                          ];
                                          
                                          return PieChartSectionData(
                                            color: colors[index % colors.length],
                                            value: value,
                                            title: '${percentage.toStringAsFixed(1)}%',
                                            radius: 60,
                                            titleStyle: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                            badgeWidget: null,
                                          );
                                        },
                                      ),
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Legend
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: List.generate(
                              salesData.length,
                              (index) {
                                final title = salesData.keys.elementAt(index);
                                final value = salesData.values.elementAt(index);
                                final colors = [
                                  const Color(0xFFD4AF37),
                                  const Color(0xFFFBD89B),
                                  const Color(0xFFC9A227),
                                  const Color(0xFFE6C954),
                                  const Color(0xFFB8922A),
                                ];
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: colors[index % colors.length],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF666666),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$value units',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
