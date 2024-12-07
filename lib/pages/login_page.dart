import 'package:flutter/material.dart';
import 'package:inventorypos/pages/homepage.dart';
import 'package:inventorypos/provider/login_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Check if auto-login is successful when the page is first loaded
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginProvider.checkAutoLogin().then((_) {
        // If user is logged in after auto-login, navigate to home page
        if (loginProvider.isLogin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => POSHomePage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/login_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo/sasa.png', width: 130),
                  const Text('Login',
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: loginProvider.usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: loginProvider.passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: loginProvider.isLoading
                        ? const ElevatedButton(
                            onPressed: null,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              final res = await loginProvider.login(context);
                              if (res == 'success') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => POSHomePage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res),
                                  ),
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
