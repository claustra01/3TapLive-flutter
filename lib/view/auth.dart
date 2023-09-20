import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:hackz_tyranno/component/button.dart';
import 'package:hackz_tyranno/component/dialog.dart';
import 'package:hackz_tyranno/view/home.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends ConsumerState<AuthPage> {

  final nameController = TextEditingController();

  void _loginWithGoogle() async {

    // input validation
    if (nameController.text.length > 20) {
      if (!mounted) return;
      showAlertDialog(context, "Note", "Display Name is too long");
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      User? user =  (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (user != null) {
        // set user display name
        if (nameController.text != '') {
          await user.updateDisplayName(nameController.text);
        }
        // route to home
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()), (_) => false);
      }
    } catch (e) {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32),
              child: TextField(
                decoration: const InputDecoration(
                  label: Text('Display Name'),
                  border: OutlineInputBorder(),
                ),
                controller: nameController,
              ),
            ),
            textButton('Login with Google', _loginWithGoogle),
          ],
        ),
      ),
    );
  }
  
}