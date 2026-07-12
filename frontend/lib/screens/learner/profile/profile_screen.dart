import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';
import '../../../services/services.dart';


// ════════════════════════════════════════════════════════════════════════════════
// SCR-L23/L24 — Profile & Edit Profile (Learner)
// Uses HomeViewModel for user info (name), AuthViewModel for logout
// ════════════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final localDt = dt.toLocal();
    final d = localDt.day.toString().padLeft(2, '0');
    final m = localDt.month.toString().padLeft(2, '0');
    final y = localDt.year;
    return '$d/$m/$y';
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Trợ giúp & Hỗ trợ'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hệ thống Flipped Classroom',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('Mọi thắc mắc hoặc yêu cầu hỗ trợ kỹ thuật, vui lòng liên hệ:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Expanded(child: Text('support@flippedclassroom.edu.vn')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text('1900 1234 (8:00 - 17:00)'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Đổi mật khẩu'),
          ],
        ),
        content: const Text('Tính năng đổi mật khẩu đang được phát triển và sẽ sẵn sàng trong bản cập nhật tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final name   = homeVm.greeting.isNotEmpty ? homeVm.greeting : 'Học viên';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1B4B), AppColors.primary],
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white.withAlpha(30),
                    backgroundImage: (homeVm.profile?.avatarUrl != null && homeVm.profile!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(homeVm.profile!.avatarUrl!)
                        : null,
                    child: (homeVm.profile?.avatarUrl == null || homeVm.profile!.avatarUrl!.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Text('Học viên', style: TextStyle(fontSize: 13, color: Colors.white60)),
                ]),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Role badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.school_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('Learner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // Info section
              _Section('Thông tin cá nhân', [
                _InfoTile(Icons.person_rounded, 'Họ tên', name),
                if (homeVm.profile != null) ...[
                  _InfoTile(Icons.email_rounded, 'Email', homeVm.profile!.email),
                  _InfoTile(Icons.calendar_today_rounded, 'Ngày tham gia', _formatDate(homeVm.profile!.createdAt)),
                ],
              ]),
              const SizedBox(height: 12),

              // Edit profile
              AppButton(
                label: 'CHỈNH SỬA THÔNG TIN',
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                variant: ButtonVariant.outline,
                icon: Icons.edit_rounded,
              ),
              const SizedBox(height: 20),

              // Settings section
              _Section('Cài đặt', [
                _ActionTile(Icons.notifications_rounded, 'Thông báo', () => Navigator.pushNamed(context, '/notifications')),
                _ActionTile(Icons.lock_rounded, 'Đổi mật khẩu', () => _showChangePasswordDialog(context)),
                _ActionTile(Icons.help_rounded, 'Trợ giúp', () => _showHelpDialog(context)),
              ]),
              const SizedBox(height: 12),

              // Logout
              AppButton(
                label: 'ĐĂNG XUẤT',
                onPressed: () async {
                  await authVm.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  }
                },
                variant: ButtonVariant.danger,
                icon: Icons.logout_rounded,
                isLoading: authVm.isLoading,
              ),
              const SizedBox(height: 40),
            ])),
          ),
        ],
      ),
    );
  }
}


// ── Edit Profile ───────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _avatarCtrl = TextEditingController();
  bool _saving     = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<HomeViewModel>().profile;
    final greeting = context.read<HomeViewModel>().greeting;
    _nameCtrl.text = profile?.fullName ?? greeting;
    _avatarCtrl.text = profile?.avatarUrl ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    
    final name = _nameCtrl.text.trim();
    final avatar = _avatarCtrl.text.trim();
    final res = await ProfileService().updateProfile(
      fullName: name,
      avatarUrl: avatar.isNotEmpty ? avatar : null,
    );
    
    if (!mounted) return;
    setState(() => _saving = false);
    
    if (res.success) {
      context.read<HomeViewModel>().init(); // Refresh profile name on home screen
      AppSnackBar.show(context, 'Cập nhật thành công!', type: SnackType.success);
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, res.error ?? 'Đã xảy ra lỗi', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chỉnh sửa thông tin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar preview
            Center(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _avatarCtrl,
                builder: (context, value, _) {
                  final url = value.text.trim();
                  return CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                    child: url.isEmpty
                        ? Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            AppTextField(
              label: 'Họ và tên *',
              hint: 'Nhập họ và tên của bạn',
              controller: _nameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Đường dẫn ảnh đại diện (Avatar URL)',
              hint: 'Nhập URL ảnh đại diện của bạn',
              controller: _avatarCtrl,
            ),
            const SizedBox(height: 32),

            AppButton(
              label: 'LƯU THAY ĐỔI',
              onPressed: _save,
              isLoading: _saving,
              icon: Icons.save_rounded,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'HỦY',
              onPressed: () => Navigator.pop(context),
              variant: ButtonVariant.outline,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 0.5)),
    const SizedBox(height: 8),
    Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: children.asMap().entries.map((e) => Column(children: [
        e.value,
        if (e.key < children.length - 1) const Divider(height: 1, indent: 56),
      ])).toList()),
    ),
  ]);
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: AppColors.primary),
    ),
    title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w500)),
    subtitle: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: AppColors.primary),
    ),
    title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    onTap: onTap,
  );
}
