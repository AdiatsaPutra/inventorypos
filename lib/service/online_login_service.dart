import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineLoginService {
  final supabase = Supabase.instance.client;

  Future<bool> login(String username, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: username, // Treat username as email
        password: password,
      );
      return response.user != null; // Successful login if no error
    } catch (e) {
      return false;
    }
  }

  Future<void> syncUser(String username, String password) async {
    // You can define the sync logic here if needed, for example updating user data.
    // In this example, we're using the sign-in method, which already handles user management.
    // Add additional syncing logic if you need to handle offline-to-online sync.
  }
}
