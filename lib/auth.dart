import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends ConsumerState<AuthPage> {

  void _googleFirebaseAuth() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page')
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _googleFirebaseAuth,
          child: const Text('Login with Google')
        ),
      ),
    );
  }
  
}