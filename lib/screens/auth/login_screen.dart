import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/auth_service.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final rawPhone = _phoneController.text.trim();
      // تسجيل دخول مباشر عبر جدول delivery_captains فقط
      await authService.signInByCaptainPhonePassword(
        rawPhone,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تسجيل الدخول: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'يرجى إدخال رقم الجوال';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (value.length < 4) return 'كلمة المرور قصيرة جداً';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DesignSystem.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Form(
                key: _formKey,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: DesignSystem.primary.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo دائرة متدرجة
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          gradient: DesignSystem.primaryGradient,
                          borderRadius: BorderRadius.circular(46),
                          boxShadow: [
                            BoxShadow(
                              color: DesignSystem.primary.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title
                      Text(
                        'تسجيل الدخول',
                        style: DesignSystem.headlineMedium.copyWith(
                          color: DesignSystem.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ادخل بياناتك للبدء في توصيل الطلبات',
                        style: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.primary.withOpacity(0.73),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Phone Field
                      DesignSystem.gradientTextFormField(
                        controller: _phoneController,
                        labelText: 'رقم الجوال',
                        hintText: 'أدخل رقم الجوال كما هو مسجل في النظام',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      DesignSystem.gradientTextFormField(
                        controller: _passwordController,
                        labelText: 'كلمة المرور',
                        hintText: 'أدخل كلمة المرور',
                        prefixIcon: Icons.lock,
                        validator: _validatePassword,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: DesignSystem.primary,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'دخول',
                                  style: DesignSystem.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Help/support
                      Text(
                        'في حالة وجود مشكلة في تسجيل الدخول، تواصل مع الدعم الفني',
                        style: DesignSystem.bodySmall.copyWith(
                          color: DesignSystem.primary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: contact support
                        },
                        icon: Icon(
                          Icons.support_agent,
                          color: DesignSystem.primary,
                          size: 20,
                        ),
                        label: Text(
                          'تواصل مع الدعم',
                          style: DesignSystem.labelMedium.copyWith(
                            color: DesignSystem.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: DesignSystem.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
