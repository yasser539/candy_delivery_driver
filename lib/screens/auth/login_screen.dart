import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../../data/repositories/delivery_captains_repository.dart';
import '../../core/session/current_captain.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _repo = DeliveryCaptainsRepository();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();
      final pass = _passwordController.text;
      final user = await _repo.authenticate(phone: phone, password: pass);
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
        );
      } else {
  CurrentCaptain.value = user;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'أدخل رقم الجوال';
    if (v.length < 6) return 'رقم الجوال غير صحيح';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'أدخل كلمة المرور';
    if (v.length < 4) return 'كلمة المرور قصيرة';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: isDark
              ? const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : ShaderMask(
                  shaderCallback: (bounds) =>
                      DesignSystem.primaryGradient.createShader(bounds),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة الدخول داخل مربع متدرّج (نفس أسلوب شاشة التسجيل)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: DesignSystem.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B46C1).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // العنوان الفرعي بنفس أسلوب شاشة التسجيل
                        Text(
                          'ادخل بياناتك للبدء\n في توصيل الطلبات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.8,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // حقل رقم الجوال — نفس تصميم حقول شاشة التسجيل (إطار متدرّج + حاوية داخلية)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                'رقم الجوال',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: DesignSystem.primaryGradient,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                  style: const TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 12,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'أدخل رقم الجوال كما هو مسجل في النظام',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[500],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // حقل كلمة المرور — نفس تصميم حقل الاسم/الهاتف في التسجيل
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                'كلمة المرور',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: DesignSystem.primaryGradient,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 12,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'أدخل كلمة المرور',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[500],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey[700],
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 90),

                        // زر الدخول — نفس زر "التالي" في التسجيل
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: DesignSystem.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B46C1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'دخول',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // زر الدعم — تنسيق بسيط متوافق
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.support_agent,
                            color: DesignSystem.primary,
                            size: 20,
                          ),
                          label: Text(
                            'تواصل مع الدعم',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 12,
                              color: DesignSystem.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: DesignSystem.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
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
      ),
    );
  }
}
