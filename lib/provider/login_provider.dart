import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:inventorypos/service/offline_login_service.dart';
import 'package:inventorypos/service/online_login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isOnline = false;
  bool isLoading = false;

  final OfflineLoginService _offlineLoginService = OfflineLoginService();
  final OnlineLoginService _onlineLoginService = OnlineLoginService();

  LoginProvider() {
    _checkConnectivity();
    checkAutoLogin(); // Check for auto login on start
  }

  Future<void> _checkConnectivity() async {
    bool result = await InternetConnection().hasInternetAccess;
    isOnline = result;
    notifyListeners();
  }

  // Auto-login check based on saved credentials
  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;
      await login(null); // Perform login automatically
    }
  }

  // Login function
  Future<String> login(BuildContext? context) async {
    String username = usernameController.text;
    String password = passwordController.text;

    isLoading = true; // Set loading to true
    notifyListeners();

    try {
      bool isSuccess;
      // Uncomment this if you want to sync online logic
      // if (isOnline) {
      //   isSuccess = await _onlineLoginService.login(username, password);
      //   if (isSuccess) {
      //     await _offlineLoginService.syncWithOnline(_onlineLoginService);
      //   }
      // } else {
      isSuccess = await _offlineLoginService.login(username, password);
      // }

      if (isSuccess) {
        // Save credentials for auto-login next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('password', password);

        return 'success';
      } else {
        return 'Invalid username or password';
      }
    } catch (e) {
      return 'Error: $e';
    } finally {
      isLoading = false; // Reset loading to false
      notifyListeners();
    }
  }

  // Logout function to clear stored credentials
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    usernameController.clear();
    passwordController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
