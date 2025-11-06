import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../controllers/auth_controller.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';
import '../screens/login_screen.dart';

class ProfileScreenNew extends StatefulWidget {
  const ProfileScreenNew({Key? key}) : super(key: key);

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  late UserProfileService userProfileService;
  late UserProfile userProfile;
  File? _selectedImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userProfileService = UserProfileService();
    _loadUserProfile();
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 40,
                    color: const Color(0xFFD4AF37),
                  ),
                ],
              ),
            ),
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
                      onTap: _pickProfileImage,
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
                                onPressed: _pickProfileImage,
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
            const SizedBox(height: 32),

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
