import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  String? _errorMessage;

  void _login() async {
    setState(() => _errorMessage = null);
    try {
      await _authService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
    body: SafeArea(
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(24.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    SizedBox(height: 80),
    Text("Welcome", style: Theme.of(context).textTheme.titleLarge),
    SizedBox(height: 16),
    TextField(
    controller: _emailController,
    decoration: InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.emailAddress,
    ),
    SizedBox(height: 16),
    TextField(
    controller: _passwordController,
    decoration: InputDecoration(
    labelText: 'Password',
    border: OutlineInputBorder(),
    ),
    obscureText: true,
    ),
    SizedBox(height: 24),
    ElevatedButton(
      key: const Key('login_button'),
    onPressed: _login,
    child: Text("Login"),
    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
    ),
    if (_errorMessage != null)
    Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
    ),
    TextButton(
    onPressed: widget.showRegisterPage,
    child: Text("Don't have an account? Register"),
    )
    ],
    ),
    ),
    ),
    );
  }
}
