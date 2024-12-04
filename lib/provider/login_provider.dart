import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:inventorypos/service/offline_login_service.dart';
import 'package:inventorypos/service/online_login_service.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isOnline = false;
  bool isLoading = false;

  final OfflineLoginService _offlineLoginService = OfflineLoginService();
  final OnlineLoginService _onlineLoginService = OnlineLoginService();

  LoginProvider() {
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    bool result = await InternetConnection().hasInternetAccess;
    isOnline = result;
    notifyListeners();
  }

  Future<String> login(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;

    isLoading = true; // Set loading to true
    notifyListeners();

    try {
      bool isSuccess;
      // if (isOnline) {
      //   isSuccess = await _onlineLoginService.login(username, password);
      // Uncomment this if sync logic is implemented
      // if (isSuccess) {
      //   await _offlineLoginService.syncWithOnline(_onlineLoginService);
      // }
      // } else {
      isSuccess = await _offlineLoginService.login(username, password);
      // }

      if (isSuccess) {
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

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
