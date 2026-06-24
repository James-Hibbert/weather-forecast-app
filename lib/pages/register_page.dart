import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;

  void _register() async {
    setState(() => _errorMessage = null);
    try {
      await _authService.registerUser(
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
      appBar: AppBar(title: Text('Register')),
    body: SafeArea(
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(24.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    SizedBox(height: 80),
    Text("Create your account", style: Theme.of(context).textTheme.titleLarge),
    SizedBox(height: 16),
    TextField(
    controller: _emailController,
    decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
    ),
    SizedBox(height: 16),
    TextField(
    controller: _passwordController,
    decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
    obscureText: true,
    ),
    SizedBox(height: 24),
    ElevatedButton(
    onPressed: _register,
    child: Text("Register"),
    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
    ),
    if (_errorMessage != null)
    Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
    ),
    TextButton(
    onPressed: widget.showLoginPage,
    child: Text("Already have an account? Login"),
    )
    ],
    ),
    ),
    ),
    );
  }
}
