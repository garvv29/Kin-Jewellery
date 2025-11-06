import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final AuthService authService = AuthService();
  
  var currentUser = Rx<User?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = authService.getCurrentUser();
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await authService.signInWithGoogle();
      currentUser.value = user;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await authService.signOut();
      currentUser.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isUserSignedIn => currentUser.value != null;
}
