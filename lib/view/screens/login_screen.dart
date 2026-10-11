import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import '../../main.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_button.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isArabic => localeNotifier.value.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid-email')) {
      return _text(
        'Please enter a valid email address.',
        'من فضلك أدخل بريدًا إلكترونيًا صحيحًا.',
      );
    }

    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return _text(
        'Incorrect email or password.',
        'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      );
    }

    if (message.contains('user-disabled')) {
      return _text(
        'This account has been disabled.',
        'تم تعطيل هذا الحساب.',
      );
    }

    if (message.contains('too-many-requests')) {
      return _text(
        'Too many attempts. Please try again later.',
        'محاولات كثيرة. حاول مرة أخرى لاحقًا.',
      );
    }

    if (message.contains('network-request-failed')) {
      return _text(
        'Network error. Check your internet connection.',
        'حدث خطأ في الاتصال. تأكد من اتصالك بالإنترنت.',
      );
    }

    return _text(
      'Login failed. Please check your details and try again.',
      'فشل تسجيل الدخول. راجع بياناتك وحاول مرة أخرى.',
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        _text(
          'Please enter your email and password.',
          'من فضلك أدخل البريد الإلكتروني وكلمة المرور.',
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(_getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Directionality(
      textDirection:
          _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _text('Login', 'تسجيل الدخول'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                _text('Welcome Back', 'مرحبًا بعودتك'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _text(
                  'Login to access your saved news.',
                  'سجّل الدخول للوصول إلى أخبارك المحفوظة.',
                ),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 35),
              Text(
                _text('Email', 'البريد الإلكتروني'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _emailController,
                hintText: _text(
                  'Enter your email',
                  'أدخل بريدك الإلكتروني',
                ),
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              Text(
                _text('Password', 'كلمة المرور'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              AuthPasswordField(
                controller: _passwordController,
                hintText: _text(
                  'Enter your password',
                  'أدخل كلمة المرور',
                ),
                obscureText: _obscurePassword,
                isDark: isDark,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 30),
              AuthButton(
                isLoading: _isLoading,
                text: _text('Login', 'تسجيل الدخول'),
                onPressed: _login,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _openRegister,
                  child: Text(
                    _text(
                      "Don't have an account? Create one",
                      'ليس لديك حساب؟ أنشئ حسابًا',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}