import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L08 — Course Detail (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class LearnerCourseDetailScreen extends StatefulWidget {
  final int courseId;
  const LearnerCourseDetailScreen({super.key, required this.courseId});
  
  @override
  State<LearnerCourseDetailScreen> createState() => _LearnerCourseDetailState();
}

class _LearnerCourseDetailState extends State<LearnerCourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadCourseDetail(widget.courseId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<CourseViewModel>();
    final course  = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(course?.title ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E1B4B), AppColors.primary],
                        ),
                      ),
                      child: const Center(child: Icon(Icons.school_rounded, size: 80, color: Colors.white30)),
                    ),
                    // Optionally overlay an image if coverImageUrl is present
                    if (course?.coverImageUrl != null && course!.coverImageUrl!.isNotEmpty)
                      Image.network(course.coverImageUrl!, fit: BoxFit.cover),
                    // Dark gradient at the bottom for text readability
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      height: 100,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (course != null && !vm.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryLight,
                            child: const Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(course.instructorName, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          const Text('12 tuần', style: TextStyle(fontSize: 13, color: AppColors.textHint)), // Placeholder duration
                          const SizedBox(width: 16),
                          const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text('${course.classes?.fold<int>(0, (prev, c) => prev + (c['memberCount'] as int? ?? 0)) ?? 0} học viên', 
                                style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
                        ],
                      ),
                      if (course.description != null && course.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(course.description!, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary)),
                      ]
                    ],
                  ),
                ),
              ),
            if (course != null && !vm.isLoading)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Lớp HK'),
                      Tab(text: 'Tài liệu'),
                      Tab(text: 'Tiến độ'),
                    ],
                  ),
                ),
              ),
          ];
        },
        body: vm.isLoading
            ? const Center(child: LoadingWidget())
            : course == null
                ? const Center(child: EmptyState(icon: Icons.error_outline, title: 'Không tìm thấy', message: ''))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Lớp học kỳ
                      _buildClassesTab(course.classes),
                      // Tab 2: Tài liệu
                      const Center(child: Text('Tài liệu khóa học (Coming soon...)', style: TextStyle(color: AppColors.textHint))),
                      // Tab 3: Tiến độ
                      const Center(child: Text('Tiến độ học tập (Coming soon...)', style: TextStyle(color: AppColors.textHint))),
                    ],
                  ),
      ),
    );
  }

  Widget _buildClassesTab(List<dynamic>? classes) {
    if (classes == null || classes.isEmpty) {
      return const Center(child: Text('Chưa có lớp học nào.', style: TextStyle(color: AppColors.textHint)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final cls = classes[i];
        return _ClassCard(
          name: cls['name'] as String? ?? 'Unnamed Class',
          startDate: cls['startDate'] as String?,
          endDate: cls['endDate'] as String?,
          memberCount: cls['memberCount'] as int? ?? 0,
          onTap: () => Navigator.pushNamed(context, '/classes/${cls['id']}'),
        );
      },
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String name;
  final String? startDate;
  final String? endDate;
  final int memberCount;
  final VoidCallback onTap;

  const _ClassCard({
    required this.name,
    this.startDate,
    this.endDate,
    required this.memberCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.class_outlined, color: AppColors.primary, size: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Row(
              children: [
                if (startDate != null) ...[
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(startDate!.split('T')[0], style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.people_outline, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text('$memberCount', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            )
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
