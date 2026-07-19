import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';

/// SCR-L01 - Kiểm tra token, redirect tới màn hình phù hợp
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final session = await AuthService().getSession();
    if (!mounted) return;

    if (session.token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else if (session.role == 'Instructor') {
      Navigator.pushReplacementNamed(context, '/instructor/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF7C3AED), AppColors.secondary],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fadeAnim,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.school_rounded, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Flipped Classroom',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Học tập hiệu quả hơn mỗi ngày',
                    style: TextStyle(fontSize: 15, color: Colors.white.withAlpha(204), fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0x33FFFFFF),
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        minHeight: 3,
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
  );
}
