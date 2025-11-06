import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  static const String _userProfileKey = 'user_profile';

  Future<UserProfile> getUserProfile(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('$_userProfileKey:$uid');
      
      if (profileJson != null) {
        return UserProfile.fromJson(jsonDecode(profileJson));
      }
      
      return UserProfile(
        uid: uid,
        name: '',
        email: '',
      );
    } catch (e) {
      print('Error getting user profile: $e');
      return UserProfile(uid: uid, name: '', email: '');
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_userProfileKey:${profile.uid}',
        jsonEncode(profile.toJson()),
      );
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  Future<void> addDeliveryAddress(String uid, DeliveryAddress address) async {
    try {
      final profile = await getUserProfile(uid);
      profile.addresses.add(address);
      await saveUserProfile(profile);
    } catch (e) {
      print('Error adding delivery address: $e');
    }
  }

  Future<void> updateDeliveryAddress(String uid, DeliveryAddress address) async {
    try {
      final profile = await getUserProfile(uid);
      final index = profile.addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        profile.addresses[index] = address;
        await saveUserProfile(profile);
      }
    } catch (e) {
      print('Error updating delivery address: $e');
    }
  }

  Future<void> deleteDeliveryAddress(String uid, String addressId) async {
    try {
      final profile = await getUserProfile(uid);
      profile.addresses.removeWhere((a) => a.id == addressId);
      await saveUserProfile(profile);
    } catch (e) {
      print('Error deleting delivery address: $e');
    }
  }

  Future<void> addPaymentMethod(String uid, PaymentMethod method) async {
    try {
      final profile = await getUserProfile(uid);
      profile.paymentMethods.add(method);
      await saveUserProfile(profile);
    } catch (e) {
      print('Error adding payment method: $e');
    }
  }

  Future<void> updatePaymentMethod(String uid, PaymentMethod method) async {
    try {
      final profile = await getUserProfile(uid);
      final index = profile.paymentMethods.indexWhere((p) => p.id == method.id);
      if (index != -1) {
        profile.paymentMethods[index] = method;
        await saveUserProfile(profile);
      }
    } catch (e) {
      print('Error updating payment method: $e');
    }
  }

  Future<void> deletePaymentMethod(String uid, String methodId) async {
    try {
      final profile = await getUserProfile(uid);
      profile.paymentMethods.removeWhere((p) => p.id == methodId);
      await saveUserProfile(profile);
    } catch (e) {
      print('Error deleting payment method: $e');
    }
  }

  Future<List<DeliveryAddress>> getDeliveryAddresses(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      return profile.addresses;
    } catch (e) {
      print('Error getting delivery addresses: $e');
      return [];
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      return profile.paymentMethods;
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }
}
