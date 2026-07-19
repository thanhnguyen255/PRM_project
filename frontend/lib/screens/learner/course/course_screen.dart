import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L03 — Course List (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class LearnerCourseListScreen extends StatefulWidget {
  const LearnerCourseListScreen({super.key});
  @override
  State<LearnerCourseListScreen> createState() => _LearnerCourseListState();
}

class _LearnerCourseListState extends State<LearnerCourseListScreen> {
  final _searchCtrl   = TextEditingController();
  String _searchQuery = '';
  String _filterTab   = 'Tất cả';

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
    final courses = vm.courses.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.instructorName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final pct = c.progressPercent ?? 0;
      final matchFilter = _filterTab == 'Tất cả' ||
          (_filterTab == 'Đang học' && pct > 0 && pct < 1) ||
          (_filterTab == 'Hoàn thành' && pct >= 1);
      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Khóa học của tôi')),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm khóa học...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: ['Tất cả', 'Đang học', 'Hoàn thành'].map((tab) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _filterTab == tab ? Colors.white : AppColors.textSecondary)),
              selected: _filterTab == tab,
              selectedColor: AppColors.primary,
              onSelected: (_) => setState(() => _filterTab = tab),
            ),
          )).toList()),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(child: vm.isLoading
            ? const LoadingWidget()
            : courses.isEmpty
                ? const EmptyState(icon: Icons.book_outlined, title: 'Không tìm thấy khóa học', message: 'Thử thay đổi bộ lọc hoặc từ khoá tìm kiếm.')
                : RefreshIndicator(
                    onRefresh: () => vm.loadMyCourses(),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => CourseCard(
                        title: courses[i].title,
                        instructorName: courses[i].instructorName,
                        coverImageUrl: courses[i].coverImageUrl,
                        progressPercent: courses[i].progressPercent,
                        onTap: () => Navigator.pushNamed(context, '/courses/${courses[i].id}'),
                      ),
                    ),
                  ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L04 — Course Detail (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class LearnerCourseDetailScreen extends StatefulWidget {
  final int courseId;
  const LearnerCourseDetailScreen({super.key, required this.courseId});
  @override
  State<LearnerCourseDetailScreen> createState() => _LearnerCourseDetailState();
}

class _LearnerCourseDetailState extends State<LearnerCourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadCourseDetail(widget.courseId);
      context.read<LearningPathViewModel>().loadPaths(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<CourseViewModel>();
    final pathVm  = context.watch<LearningPathViewModel>();
    final course  = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(course?.title ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1B4B), AppColors.primary],
                  ),
                ),
                child: const Center(child: Icon(Icons.school_rounded, size: 64, color: Colors.white30)),
              ),
            ),
          ),

          if (vm.isLoading)
            const SliverFillRemaining(child: LoadingWidget())
          else if (course == null)
            const SliverFillRemaining(child: EmptyState(icon: Icons.error_outline, title: 'Không tìm thấy', message: ''))
          else ...[
            // Info card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if ((course.description ?? '').isNotEmpty) ...[
                      const Text('Mô tả', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textHint)),
                      const SizedBox(height: 6),
                      Text(course.description!, style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textSecondary)),
                      const SizedBox(height: 14),
                    ],
                    Row(children: [
                      const Icon(Icons.person_rounded, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 6),
                      Text('GV: ${course.instructorName ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const Spacer(),
                      // Overall progress
                      _ProgressBadge(course.progressPercent ?? 0),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: course.progressPercent ?? 0,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(
                          (course.progressPercent ?? 0) >= 1.0 ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            // Learning paths
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('Lộ trình học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
            ),
            if (pathVm.isLoading)
              const SliverToBoxAdapter(child: LoadingWidget())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList.separated(
                  itemCount: pathVm.paths.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = pathVm.paths[i];
                    return _WeekCard(
                      weekNumber: p.weekNumber,
                      title: p.title,
                      totalActivities: p.totalActivities,
                      completedActivities: p.completedActivities,
                      progress: p.progress,
                      onTap: () => Navigator.pushNamed(context, '/learning-paths/${p.id}'),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final double pct;
  const _ProgressBadge(this.pct);
  @override
  Widget build(BuildContext context) {
    final color = pct >= 1.0 ? AppColors.success : pct >= 0.5 ? AppColors.info : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(20)),
      child: Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _WeekCard extends StatelessWidget {
  final int weekNumber;
  final String title;
  final int totalActivities;
  final int completedActivities;
  final double progress;
  final VoidCallback onTap;

  const _WeekCard({
    required this.weekNumber, required this.title,
    required this.totalActivities, required this.completedActivities,
    required this.progress, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isComplete ? AppColors.success.withAlpha(80) : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isComplete ? AppColors.successLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isComplete
                ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
                : Center(child: Text('W$weekNumber', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('$completedActivities/$totalActivities hoạt động', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(isComplete ? AppColors.success : AppColors.primary),
                minHeight: 5,
              ),
            ),
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ),
    );
  }
}
