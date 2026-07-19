import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_colors.dart';
import '../../../config/api_config.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';
import '../../../services/services.dart';


// ════════════════════════════════════════════════════════════════════════════════
// SCR-L40/L41 — Profile & Edit Profile (Learner)
// Uses HomeViewModel for user info (name), AuthViewModel for logout
// ════════════════════════════════════════════════════════════════════════════════

// Ghép đường dẫn media tương đối từ server ('/uploads/..') thành URL tuyệt đối để hiển thị.
String _mediaUrl(String path) {
  if (path.startsWith('http')) return path;
  var base = ApiConfig.baseUrl;
  if (base.endsWith('/api')) {
    base = base.substring(0, base.length - 4);
  } else if (base.endsWith('/api/')) {
    base = base.substring(0, base.length - 5);
  }
  if (base.endsWith('/')) base = base.substring(0, base.length - 1);
  return '$base$path';
}
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
    final isInstructor = homeVm.profile?.role == 'Instructor';
    final name   = homeVm.greeting.isNotEmpty ? homeVm.greeting : (isInstructor ? 'Giảng viên' : 'Học viên');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
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
                        ? NetworkImage(_mediaUrl(homeVm.profile!.avatarUrl!))
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
                  Text(isInstructor ? 'Giảng viên' : 'Học viên', style: const TextStyle(fontSize: 13, color: Colors.white60)),
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
                  decoration: BoxDecoration(
                    color: isInstructor ? AppColors.secondary.withAlpha(30) : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      isInstructor ? Icons.shield_rounded : Icons.school_rounded,
                      size: 14,
                      color: isInstructor ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isInstructor ? 'Giảng viên' : 'Learner',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isInstructor ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
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
                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (_) => false);
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
  bool _saving     = false;

  Uint8List? _avatarBytes;      // ảnh mới chọn (bytes — chạy được cả trên web)
  String? _avatarFileName;
  String? _existingAvatarUrl;   // avatar hiện tại (đường dẫn từ server)

  @override
  void initState() {
    super.initState();
    final profile = context.read<HomeViewModel>().profile;
    final greeting = context.read<HomeViewModel>().greeting;
    _nameCtrl.text = profile?.fullName ?? greeting;
    _existingAvatarUrl = profile?.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _avatarFileName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final res = await ProfileService().updateProfile(
      fullName: _nameCtrl.text.trim(),
      avatarBytes: _avatarBytes,
      avatarFileName: _avatarFileName,
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
    final ImageProvider? avatarImage = _avatarBytes != null
        ? MemoryImage(_avatarBytes!)
        : (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty
            ? NetworkImage(_mediaUrl(_existingAvatarUrl!))
            : null);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chỉnh sửa thông tin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar picker
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primary),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _pickAvatar,
                icon: const Icon(Icons.image_rounded, size: 18),
                label: const Text('Chọn ảnh đại diện'),
              ),
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Họ và tên *',
              hint: 'Nhập họ và tên của bạn',
              controller: _nameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
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
    Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(children: children.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < children.length - 1) const Divider(height: 1, indent: 56),
        ])).toList()),
      ),
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
