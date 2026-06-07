import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/viewmodels.dart';
import '../../widgets/widgets.dart';

/// SCR-L02 - Đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm   = context.read<AuthViewModel>();
    final role = await vm.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (role != null) {
      if (role == 'Instructor') {
        Navigator.pushReplacementNamed(context, '/instructor/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (vm.error != null) {
      AppSnackBar.show(context, vm.error!, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Header
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 24),
                    const Text('Xin chào 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Đăng nhập để tiếp tục học tập', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    const SizedBox(height: 40),

                    // Email
                    AppTextField(
                      label: 'Email',
                      hint: 'email@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                        if (!v.contains('@')) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AppTextField(
                      label: 'Mật khẩu',
                      hint: '••••••••',
                      controller: _passCtrl,
                      obscureText: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textHint),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                    ),
                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Login button
                    AppButton(
                      label: 'ĐĂNG NHẬP',
                      onPressed: _submit,
                      isLoading: vm.isLoading,
                    ),
                    const SizedBox(height: 32),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chưa có tài khoản?', style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Đăng ký ngay', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
