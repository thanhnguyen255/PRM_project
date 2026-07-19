import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L04 — Forgot Password Screen (3 bước: Email → OTP → New Password)
// ════════════════════════════════════════════════════════════════════════════════
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0=email, 1=otp, 2=new password
  bool _isLoading = false;

  // Step 0
  final _emailCtrl = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  // Step 1
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 60;
  bool _canResend = false;

  // Step 2
  final _newPassCtrl   = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _passFormKey   = GlobalKey<FormState>();
  bool _showNew        = false;
  bool _showConfirm    = false;

  String? _resetToken;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) _canResend = true;
      });
      return _resendCountdown > 0;
    });
  }

  String get _otpCode => _otpCtrls.map((c) => c.text).join();

  Future<void> _sendOTP() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final res = await ApiService.instance.post('/auth/forgot-password', data: {
      'email': _emailCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res['success'] == true) {
      setState(() => _step = 1);
      _startCountdown();
    } else {
      AppSnackBar.show(context, res['message'] as String? ?? 'Không tìm thấy tài khoản.', type: SnackType.error);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length < 6) {
      AppSnackBar.show(context, 'Vui lòng nhập đủ 6 số OTP.', type: SnackType.warning);
      return;
    }
    setState(() => _isLoading = true);
    final res = await ApiService.instance.post('/auth/verify-otp', data: {
      'email': _emailCtrl.text.trim(),
      'otp':   _otpCode,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res['success'] == true) {
      _resetToken = res['data']?['token'] as String? ?? _otpCode;
      setState(() => _step = 2);
    } else {
      AppSnackBar.show(context, res['message'] as String? ?? 'OTP không đúng hoặc đã hết hạn.', type: SnackType.error);
    }
  }

  Future<void> _resetPassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final res = await ApiService.instance.post('/auth/reset-password', data: {
      'email':       _emailCtrl.text.trim(),
      'resetToken':  _resetToken,
      'newPassword': _newPassCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res['success'] == true) {
      AppSnackBar.show(context, 'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.', type: SnackType.success);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      AppSnackBar.show(context, res['message'] as String? ?? 'Không thể đặt lại mật khẩu.', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => _step == 0 ? Navigator.pop(context) : setState(() => _step--),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              _StepIndicator(currentStep: _step),
              const SizedBox(height: 32),

              // Content per step
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: switch (_step) {
                  0 => _EmailStep(
                    key: const ValueKey(0),
                    formKey: _emailFormKey,
                    controller: _emailCtrl,
                    isLoading: _isLoading,
                    onNext: _sendOTP,
                  ),
                  1 => _OtpStep(
                    key: const ValueKey(1),
                    email: _emailCtrl.text.trim(),
                    controllers: _otpCtrls,
                    focusNodes: _otpFocus,
                    countdown: _resendCountdown,
                    canResend: _canResend,
                    isLoading: _isLoading,
                    onVerify: _verifyOTP,
                    onResend: () async {
                      setState(() => _isLoading = true);
                      await ApiService.instance.post('/auth/forgot-password', data: {'email': _emailCtrl.text.trim()});
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      _startCountdown();
                      AppSnackBar.show(context, 'Đã gửi lại OTP.', type: SnackType.success);
                    },
                  ),
                  _ => _NewPasswordStep(
                    key: const ValueKey(2),
                    formKey: _passFormKey,
                    newPassCtrl: _newPassCtrl,
                    confirmCtrl: _confirmCtrl,
                    showNew: _showNew,
                    showConfirm: _showConfirm,
                    isLoading: _isLoading,
                    onToggleNew: () => setState(() => _showNew = !_showNew),
                    onToggleConfirm: () => setState(() => _showConfirm = !_showConfirm),
                    onSubmit: _resetPassword,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Email', 'Mã OTP', 'Mật khẩu mới'];
    return Row(
      children: List.generate(3, (i) {
        final isActive  = i == currentStep;
        final isDone    = i < currentStep;
        return Expanded(
          child: Row(children: [
            Expanded(child: Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 36 : 28,
                height: isActive ? 36 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.success : isActive ? AppColors.primary : AppColors.surfaceVariant,
                  boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withAlpha(60), blurRadius: 12, spreadRadius: 2)] : null,
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.circle_outlined,
                  size: isActive ? 20 : 14,
                  color: isDone || isActive ? Colors.white : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.primary : isDone ? AppColors.success : AppColors.textHint,
                ),
              ),
            ])),
            if (i < 2)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.success : AppColors.border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

// ─── Step 0: Email ────────────────────────────────────────────────────────────
class _EmailStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onNext;

  const _EmailStep({super.key, required this.formKey, required this.controller, required this.isLoading, required this.onNext});

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quên mật khẩu?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      const Text('Nhập email tài khoản của bạn. Chúng tôi sẽ gửi mã OTP để xác nhận.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      const SizedBox(height: 32),

      // Email icon + field
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.email_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Địa chỉ Email', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                Text('Dùng để xác nhận tài khoản', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              ])),
            ]),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.textHint),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Email không hợp lệ';
                return null;
              },
            ),
          ]),
        ),
      ),
      const SizedBox(height: 32),

      AppButton(label: 'GỬI MÃ OTP', onPressed: onNext, isLoading: isLoading, icon: Icons.send_rounded),
      const SizedBox(height: 20),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Nhớ mật khẩu rồi? ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('Đăng nhập', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ]),
    ]),
  );
}

// ─── Step 1: OTP ─────────────────────────────────────────────────────────────
class _OtpStep extends StatelessWidget {
  final String email;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int countdown;
  final bool canResend;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpStep({
    super.key,
    required this.email,
    required this.controllers,
    required this.focusNodes,
    required this.countdown,
    required this.canResend,
    required this.isLoading,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Nhập mã OTP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    const SizedBox(height: 8),
    RichText(text: TextSpan(style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
      children: [
        const TextSpan(text: 'Mã OTP đã được gửi đến '),
        TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        const TextSpan(text: '. Kiểm tra hộp thư của bạn.'),
      ],
    )),
    const SizedBox(height: 40),

    // OTP boxes
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
        controller: controllers[i],
        focusNode: focusNodes[i],
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) focusNodes[i + 1].requestFocus();
          if (v.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
        },
      )),
    ),
    const SizedBox(height: 32),

    AppButton(label: 'XÁC NHẬN OTP', onPressed: onVerify, isLoading: isLoading, icon: Icons.verified_rounded),
    const SizedBox(height: 20),

    Center(child: canResend
        ? GestureDetector(
            onTap: onResend,
            child: const Text.rich(TextSpan(children: [
              TextSpan(text: 'Không nhận được mã? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              TextSpan(text: 'Gửi lại', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
            ])),
          )
        : Text.rich(TextSpan(children: [
            const TextSpan(text: 'Gửi lại sau ', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
            TextSpan(text: '${countdown}s', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
          ])),
    ),
  ]);
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46, height: 56,
    child: TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: onChanged,
    ),
  );
}

// ─── Step 2: New Password ─────────────────────────────────────────────────────
class _NewPasswordStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPassCtrl;
  final TextEditingController confirmCtrl;
  final bool showNew;
  final bool showConfirm;
  final bool isLoading;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  const _NewPasswordStep({
    super.key,
    required this.formKey,
    required this.newPassCtrl,
    required this.confirmCtrl,
    required this.showNew,
    required this.showConfirm,
    required this.isLoading,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Đặt mật khẩu mới', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      const Text('Tạo mật khẩu mạnh với ít nhất 8 ký tự, bao gồm chữ hoa và số.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      const SizedBox(height: 32),

      AppTextField(
        label: 'Mật khẩu mới *',
        hint: '••••••••',
        controller: newPassCtrl,
        obscureText: !showNew,
        suffixIcon: IconButton(
          icon: Icon(showNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textHint),
          onPressed: onToggleNew,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
          if (v.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
          if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Phải có ít nhất một chữ hoa';
          if (!RegExp(r'[0-9]').hasMatch(v)) return 'Phải có ít nhất một chữ số';
          return null;
        },
      ),
      const SizedBox(height: 16),

      AppTextField(
        label: 'Xác nhận mật khẩu *',
        hint: '••••••••',
        controller: confirmCtrl,
        obscureText: !showConfirm,
        suffixIcon: IconButton(
          icon: Icon(showConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textHint),
          onPressed: onToggleConfirm,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
          if (v != newPassCtrl.text) return 'Mật khẩu không khớp';
          return null;
        },
      ),
      const SizedBox(height: 24),

      // Password strength indicator
      _PasswordStrength(password: newPassCtrl.text),
      const SizedBox(height: 32),

      AppButton(label: 'ĐẶT LẠI MẬT KHẨU', onPressed: onSubmit, isLoading: isLoading, icon: Icons.lock_reset_rounded),
    ]),
  );
}

class _PasswordStrength extends StatelessWidget {
  final String password;
  const _PasswordStrength({required this.password});

  int get _strength {
    int s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final s = _strength;
    if (password.isEmpty) return const SizedBox.shrink();
    final (label, color) = switch (s) {
      0 || 1 => ('Yếu', AppColors.error),
      2      => ('Trung bình', AppColors.warning),
      3      => ('Mạnh', AppColors.info),
      _      => ('Rất mạnh', AppColors.success),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Row(children: List.generate(4, (i) => Expanded(child: Container(
          height: 4,
          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          decoration: BoxDecoration(
            color: i < s ? color : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ))))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ]),
    ]);
  }
}
