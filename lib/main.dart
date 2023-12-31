import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'package:hackz_tyranno/view/home.dart';
import 'package:hackz_tyranno/view/auth.dart';

Future<void> main() async {

  // load .env
  await dotenv.load(fileName: '.env');

  // init firebase app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3taplive',
      theme: _buildCustomTheme(),
      home: StreamBuilder<User?> (
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            // user is logged in
            return const HomePage();
          }
          return const AuthPage();
        }
      ),
    );
  }
}

ThemeData _buildCustomTheme() {
  var baseTheme = ThemeData.dark(
    useMaterial3: true,
  );
  return baseTheme.copyWith(
    textTheme: GoogleFonts.murechoTextTheme(baseTheme.textTheme),
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.indigo
    ),
  );
}