import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'view/screens/home_screen.dart';
import 'view/screens/login_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NewslyApp());
}

class NewslyApp extends StatelessWidget {
  const NewslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Newsly',

          themeMode: themeMode,

          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF3B82F6),
              elevation: 0,
              centerTitle: true,
              foregroundColor: Colors.white,
            ),
          ),

          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF3B82F6),
              elevation: 0,
              centerTitle: true,
              foregroundColor: Colors.white,
            ),
          ),

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasData) {
                return const HomeScreen();
              }

              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}