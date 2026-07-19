import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/viewmodels.dart';
import '../../widgets/widgets.dart';

/// SCR-L05 - Home Dashboard (Learner)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _CoursesTab(),
          _ProgressTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF7C3AED)],
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${vm.greeting} 👋',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Hôm nay bạn học gì?', style: TextStyle(fontSize: 14, color: Color(0xCCFFFFFF))),
                  ],
                )),
                // Notification bell
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                      ),
                      if (vm.unreadCount > 0)
                        Positioned(
                          top: -4, right: -4,
                          child: Container(
                            width: 18, height: 18,
                            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                            child: Center(child: Text('${vm.unreadCount}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (vm.isLoading)
          const SliverFillRemaining(child: LoadingWidget())
        else ...[
          // My Courses section
          if (vm.courses.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Khóa học của tôi',
                actionLabel: 'Xem tất cả',
                onAction: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vm.courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final c = vm.courses[i];
                    return CourseCard(
                      width: 200,
                      title: c.title,
                      instructorName: c.instructorName,
                      coverImageUrl: c.coverImageUrl,
                      progressPercent: c.progressPercent,
                      onTap: () => Navigator.pushNamed(context, '/courses/${c.id}'),
                    );
                  },
                ),
              ),
            ),
          ] else
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.book_outlined,
                title: 'Chưa có khóa học',
                message: 'Bạn chưa được đăng ký vào khóa học nào.',
              ),
            ),

          // Upcoming activities
          if (vm.upcoming.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Hoạt động sắp đến'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: vm.upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = vm.upcoming[i];
                  return ActivityCard(
                    title: a.title,
                    type: a.type,
                    deadline: a.deadline,
                    submissionStatus: a.submissionStatus,
                    onTap: () => Navigator.pushNamed(context, '/activities/${a.id}'),
                  );
                },
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ],
    );
  }
}

// ─── Courses Tab (placeholder → dùng chung CourseViewModel) ──────────────────
class _CoursesTab extends StatefulWidget {
  const _CoursesTab();
  @override
  State<_CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<_CoursesTab> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadMyCourses();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseViewModel>();

    return Column(children: [
      // App bar area
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
        child: Column(children: [
          const Align(alignment: Alignment.centerLeft, child: Text('Khóa học của tôi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm khóa học...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: vm.setSearch,
          ),
        ]),
      ),
      const Divider(height: 1),
      Expanded(child: vm.isLoading
          ? const LoadingWidget()
          : vm.courses.isEmpty
              ? const EmptyState(icon: Icons.book_outlined, title: 'Chưa có khóa học', message: 'Bạn chưa được thêm vào khóa học nào.')
              : RefreshIndicator(
                  onRefresh: vm.loadMyCourses,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = vm.courses[i];
                      return CourseCard(
                        title: c.title,
                        instructorName: c.instructorName,
                        coverImageUrl: c.coverImageUrl,
                        progressPercent: c.progressPercent,
                        onTap: () => Navigator.pushNamed(context, '/courses/${c.id}'),
                      );
                    },
                  ),
                ),
      ),
    ]);
  }
}

// ─── Progress Tab placeholder ─────────────────────────────────────────────────
class _ProgressTab extends StatelessWidget {
  const _ProgressTab();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Progress - Coming Soon', style: TextStyle(fontSize: 18, color: AppColors.textHint))),
  );
}

// ─── Profile Tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              const Text('Học viên', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const Text('learner@student.edu.vn', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
            ]),
          ),
          const SizedBox(height: 16),
          // Menu items
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              _profileTile(Icons.edit_rounded, 'Chỉnh sửa hồ sơ', () {}),
              const Divider(height: 1),
              _profileTile(Icons.lock_rounded, 'Đổi mật khẩu', () {}),
              const Divider(height: 1),
              _profileTile(Icons.logout_rounded, 'Đăng xuất', () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Xác nhận đăng xuất',
                  message: 'Bạn có chắc muốn đăng xuất?',
                  confirmLabel: 'Đăng xuất',
                  isDanger: true,
                );
                if (confirmed == true && context.mounted) {
                  await context.read<AuthViewModel>().logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                }
              }, color: AppColors.error),
            ]),
          ),
        ]),
      ),
    ),
  );

  Widget _profileTile(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color ?? AppColors.primary, size: 18),
    ),
    title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color ?? AppColors.textPrimary)),
    trailing: Icon(Icons.chevron_right_rounded, color: color ?? AppColors.textHint),
    onTap: onTap,
  );
}
