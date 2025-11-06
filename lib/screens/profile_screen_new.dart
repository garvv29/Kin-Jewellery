import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../controllers/auth_controller.dart';
import '../models/user_profile_model.dart';
import '../models/order_model.dart';
import '../services/user_profile_service.dart';
import '../services/order_service.dart';
import '../screens/login_screen.dart';
import '../screens/order_history_screen.dart';

class ProfileScreenNew extends StatefulWidget {
  const ProfileScreenNew({Key? key}) : super(key: key);

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  late UserProfileService userProfileService;
  late OrderService orderService;
  late UserProfile userProfile;
  File? _selectedImage;
  bool isLoading = true;
  List<Order> orderHistory = [];

  @override
  void initState() {
    super.initState();
    userProfileService = UserProfileService();
    orderService = OrderService();
    _loadUserProfile();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    final orders = await orderService.getOrders();
    setState(() {
      orderHistory = orders;
    });
  }

  Future<void> _loadUserProfile() async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    
    if (user != null) {
      final profile = await userProfileService.getUserProfile(user.uid);
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      
      // Convert image to base64 for storage
      final bytes = await _selectedImage!.readAsBytes();
      final base64String = base64Encode(bytes);
      
      setState(() {
        userProfile.profileImageUrl = base64String;
      });
      
      await userProfileService.saveUserProfile(userProfile);
      
      Get.snackbar(
        'Success',
        'Profile picture updated',
        backgroundColor: const Color(0xFFD4AF37),
        colorText: const Color(0xFF1A1A1A),
      );
    }
  }

  Future<void> _useGoogleProfilePicture() async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    
    if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
      // Store the Google photo URL directly
      setState(() {
        userProfile.profileImageUrl = user.photoURL!;
      });
      
      await userProfileService.saveUserProfile(userProfile);
      
      Get.snackbar(
        'Success',
        'Google profile picture applied',
        backgroundColor: const Color(0xFFD4AF37),
        colorText: const Color(0xFF1A1A1A),
      );
    } else {
      Get.snackbar(
        'Error',
        'No profile picture from Google account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showProfilePictureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile Picture Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFFD4AF37)),
                title: const Text('Upload from Gallery'),
                subtitle: const Text('Choose image or GIF'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage();
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Color(0xFFD4AF37)),
                title: const Text('Use Google Profile Picture'),
                subtitle: const Text('From your Google account'),
                onTap: () {
                  Navigator.pop(context);
                  _useGoogleProfilePicture();
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeProfilePicture() async {
    setState(() {
      _selectedImage = null;
      userProfile.profileImageUrl = null;
    });
    
    await userProfileService.saveUserProfile(userProfile);
    
    Get.snackbar(
      'Success',
      'Profile picture removed',
      backgroundColor: const Color(0xFFD4AF37),
      colorText: const Color(0xFF1A1A1A),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
          ),
        ),
      );
    }

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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: () => _showProfilePictureOptions(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFD4AF37).withOpacity(0.3),
                                  const Color(0xFFD4AF37).withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: _selectedImage != null
                                ? CircleAvatar(
                                    radius: 60,
                                    backgroundImage: FileImage(_selectedImage!),
                                  )
                                : user != null && user.photoURL != null && user.photoURL!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(
                                          '${user.photoURL}?sz=500',
                                        ),
                                      )
                                    : userProfile.profileImageUrl != null && userProfile.profileImageUrl!.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 60,
                                            backgroundImage: MemoryImage(
                                              base64Decode(userProfile.profileImageUrl!),
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 60,
                                            backgroundColor: Colors.grey[100],
                                            child: const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Color(0xFFD4AF37),
                                            ),
                                          ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => _showProfilePictureOptions(context),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF1A1A1A),
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // User Info
                    Text(
                      userProfile.name.isNotEmpty ? userProfile.name : user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProfile.email.isNotEmpty ? userProfile.email : user?.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => _showEditProfileDialog(context, user),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsCard(
                    icon: Icons.location_on,
                    title: 'Delivery Addresses',
                    subtitle: 'Manage your delivery addresses',
                    onTap: () => _showAddressesDialog(context),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsCard(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage your payment cards',
                    onTap: () => _showPaymentMethodsDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Divider
            Divider(color: Colors.grey[200], thickness: 1),
            const SizedBox(height: 40),

            // My Orders Navigation Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Get.to(() => const OrderHistoryScreen()),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD4AF37), Color(0xFFFBD89B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF1A1A1A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Orders',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View all ${orderHistory.length} orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A1A1A).withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF1A1A1A),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLogoutCard(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Golden Header with Order ID
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD4AF37), Color(0xFFC9A227)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_outlined, color: Color(0xFF1A1A1A), size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Row (Date, Items, Time)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Date',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(order.orderDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total Items',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${order.items.length}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Order Time',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatTime(order.orderDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Items Section
                      Text(
                        'Ordered Items (${order.items.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.grey[150], height: 1),
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            final itemTotal = item['price'] * item['quantity'];
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? 'Product',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Qty: ${item['quantity']}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '₹${item['price'].toStringAsFixed(2)}/each',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '₹${itemTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Delivery Address
                      if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.blue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delivery Address',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      order.deliveryAddress!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.6,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Payment & Delivery Row
                      Row(
                        children: [
                          if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.payment, color: Colors.green[700], size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Payment',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      order.paymentMethod!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
                            const SizedBox(width: 12),
                          if (order.estimatedDelivery != null)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: Colors.purple[700], size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Est. Delivery',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.purple[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      order.estimatedDelivery != null 
                                        ? _formatDate(order.estimatedDelivery!)
                                        : 'Not specified',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tracking ID
                      if (order.trackingId != null && order.trackingId!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.local_shipping, color: Colors.orange[700], size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tracking ID',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.trackingId!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Total Amount
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFD4AF37).withOpacity(0.15),
                              const Color(0xFFD4AF37).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Order Amount',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF1A1A1A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Close Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    try {
      final year = dateTime.year;
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (e) {
      return '--/--/--';
    }
  }

  String _formatTime(DateTime dateTime) {
    try {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final second = dateTime.second.toString().padLeft(2, '0');
      return '$hour:$minute:$second';
    } catch (e) {
      return '--:--:--';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sign out from your account',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: userProfile.name.isNotEmpty ? userProfile.name : user?.displayName ?? '');
    final phoneController = TextEditingController(text: userProfile.phone ?? '');
    final dobController = TextEditingController(text: userProfile.dateOfBirth?.toString().split(' ')[0] ?? '');
    String selectedGender = userProfile.gender ?? 'Not specified';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Edit Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Full Name', nameController),
                  const SizedBox(height: 12),
                  _buildTextField('Phone Number', phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField('Date of Birth (YYYY-MM-DD)', dobController),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: ['Male', 'Female', 'Other', 'Not specified']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => selectedGender = value ?? 'Not specified',
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.person, color: Color(0xFFD4AF37)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            userProfile.name = nameController.text;
                            userProfile.phone = phoneController.text;
                            userProfile.gender = selectedGender;
                            if (dobController.text.isNotEmpty) {
                              userProfile.dateOfBirth = DateTime.parse(dobController.text);
                            }
                            userProfileService.saveUserProfile(userProfile);
                            Get.snackbar('Success', 'Profile updated successfully',
                              backgroundColor: const Color(0xFFD4AF37),
                              colorText: const Color(0xFF1A1A1A),
                            );
                            Navigator.pop(context);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Save', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddressesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('My Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (userProfile.addresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No addresses saved yet', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: userProfile.addresses.length,
                      itemBuilder: (context, index) {
                        final address = userProfile.addresses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18),
                                          onPressed: () => _showAddAddressDialog(context, address),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          onPressed: () {
                                            userProfileService.deleteDeliveryAddress(userProfile.uid, address.id);
                                            setState(() => userProfile.addresses.removeWhere((a) => a.id == address.id));
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text('${address.street}, ${address.city}, ${address.state} ${address.zipCode}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showAddAddressDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('+ Add Address', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddAddressDialog(BuildContext context, [DeliveryAddress? existingAddress]) {
    final labelController = TextEditingController(text: existingAddress?.label ?? '');
    final streetController = TextEditingController(text: existingAddress?.street ?? '');
    final cityController = TextEditingController(text: existingAddress?.city ?? '');
    final stateController = TextEditingController(text: existingAddress?.state ?? '');
    final zipController = TextEditingController(text: existingAddress?.zipCode ?? '');
    final phoneController = TextEditingController(text: existingAddress?.phone ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Delivery Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField('Label (Home, Office, etc)', labelController),
                  const SizedBox(height: 12),
                  _buildTextField('Street Address', streetController, maxLines: 2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('City', cityController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('State', stateController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('ZIP Code', zipController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Phone', phoneController, keyboardType: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (labelController.text.isEmpty || streetController.text.isEmpty) {
                              Get.snackbar('Error', 'Please fill all fields', backgroundColor: Colors.red, colorText: Colors.white);
                              return;
                            }
                            
                            final address = DeliveryAddress(
                              id: existingAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              label: labelController.text,
                              street: streetController.text,
                              city: cityController.text,
                              state: stateController.text,
                              zipCode: zipController.text,
                              phone: phoneController.text,
                            );
                            
                            if (existingAddress != null) {
                              userProfileService.updateDeliveryAddress(userProfile.uid, address);
                            } else {
                              userProfileService.addDeliveryAddress(userProfile.uid, address);
                            }
                            
                            Get.snackbar('Success', 'Address saved', backgroundColor: const Color(0xFFD4AF37), colorText: const Color(0xFF1A1A1A));
                            Navigator.pop(context);
                            Navigator.pop(context);
                            _loadUserProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Save', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentMethodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('My Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (userProfile.paymentMethods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No payment methods saved yet', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: userProfile.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = userProfile.paymentMethods[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(method.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(method.maskedCardNumber, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () => _showAddPaymentMethodDialog(context, method),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                      onPressed: () {
                                        userProfileService.deletePaymentMethod(userProfile.uid, method.id);
                                        setState(() => userProfile.paymentMethods.removeWhere((p) => p.id == method.id));
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showAddPaymentMethodDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('+ Add Card', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context, [PaymentMethod? existingMethod]) {
    final labelController = TextEditingController(text: existingMethod?.label ?? '');
    final cardNumberController = TextEditingController(text: existingMethod?.cardNumber ?? '');
    final cardHolderController = TextEditingController(text: existingMethod?.cardHolder ?? '');
    final expiryController = TextEditingController(text: existingMethod?.expiry ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Payment Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField('Card Label', labelController),
                  const SizedBox(height: 12),
                  _buildTextField('Card Number', cardNumberController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField('Cardholder Name', cardHolderController),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('MM/YY', expiryController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('CVV', TextEditingController(), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (labelController.text.isEmpty || cardNumberController.text.isEmpty) {
                              Get.snackbar('Error', 'Please fill all fields', backgroundColor: Colors.red, colorText: Colors.white);
                              return;
                            }
                            
                            final method = PaymentMethod(
                              id: existingMethod?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              label: labelController.text,
                              cardNumber: cardNumberController.text,
                              cardHolder: cardHolderController.text,
                              expiry: expiryController.text,
                            );
                            
                            if (existingMethod != null) {
                              userProfileService.updatePaymentMethod(userProfile.uid, method);
                            } else {
                              userProfileService.addPaymentMethod(userProfile.uid, method);
                            }
                            
                            Get.snackbar('Success', 'Card saved', backgroundColor: const Color(0xFFD4AF37), colorText: const Color(0xFF1A1A1A));
                            Navigator.pop(context);
                            Navigator.pop(context);
                            _loadUserProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Save', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.logout, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Logout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 12),
                const Text('Are you sure you want to logout?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final authController = Get.find<AuthController>();
                          authController.signOut();
                          Get.offAll(() => const LoginScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
