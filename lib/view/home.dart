import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hackz_tyranno/component/dialog.dart';
import 'package:hackz_tyranno/view/auth.dart';
import 'package:hackz_tyranno/view/agora.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage()));
    } catch (e) {
      // view error dialog
      if (!mounted) return;
      showAlertDialog(context, "Error", "Logout failed");
    }
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _redirectToAgoraPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AgoraTest()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Application for Tyranno-Cup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              heroTag: 'startStreamButton',
              onPressed: _redirectToAgoraPage,
              child: const Icon(Icons.video_call_outlined),
            ),
          ),
          FloatingActionButton(
            heroTag: 'logoutButton',
            onPressed: _logout,
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
