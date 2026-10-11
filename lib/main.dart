import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'view/screens/login_screen.dart';
import 'view/screens/main_navigation_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.dark);

final ValueNotifier<Locale> localeNotifier =
    ValueNotifier(const Locale('en'));

final ValueNotifier<double> fontScaleNotifier =
    ValueNotifier(1.0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _loadAppPreferences();

  runApp(const NewslyApp());
}

Future<void> _loadAppPreferences() async {
  final prefs = await SharedPreferences.getInstance();

  final savedLanguage =
      prefs.getString('newsly_language') ?? 'English';

  localeNotifier.value = savedLanguage == 'العربية'
      ? const Locale('ar')
      : const Locale('en');

  final savedFontSize =
      prefs.getString('newsly_font_size') ?? 'Medium';

  switch (savedFontSize) {
    case 'Small':
      fontScaleNotifier.value = 0.85;
      break;
    case 'Large':
      fontScaleNotifier.value = 1.20;
      break;
    default:
      fontScaleNotifier.value = 1.0;
  }

  final isDark = prefs.getBool('newsly_dark_mode');

  if (isDark != null) {
    themeNotifier.value =
        isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class NewslyApp extends StatelessWidget {
  const NewslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, child) {
            return ValueListenableBuilder<double>(
              valueListenable: fontScaleNotifier,
              builder: (context, fontScale, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Newsly',
                  themeMode: themeMode,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  locale: locale,
                  supportedLocales: const [
                    Locale('en'),
                    Locale('ar'),
                  ],
                  builder: (context, child) {
                    final mediaQuery = MediaQuery.of(context);

                    return MediaQuery(
                      data: mediaQuery.copyWith(
                        textScaler: TextScaler.linear(fontScale),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
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
                        return const MainNavigationScreen();
                      }

                      return const LoginScreen();
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}