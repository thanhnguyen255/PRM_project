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
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<CourseViewModel>();
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
                    ]),
                  ]),
                ),
              ),
            ),

            // Classes list
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('Danh sách lớp học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
            ),
            
            if (course.classes == null || course.classes!.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Chưa có lớp học nào.', style: TextStyle(color: AppColors.textHint))),
                )
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList.separated(
                  itemCount: course.classes!.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final cls = course.classes![i];
                    return _ClassCard(
                      name: cls['name'] as String? ?? 'Unnamed Class',
                      startDate: cls['startDate'] as String?,
                      endDate: cls['endDate'] as String?,
                      memberCount: cls['memberCount'] as int? ?? 0,
                      onTap: () => Navigator.pushNamed(context, '/classes/${cls['id']}'),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.class_outlined, color: AppColors.primary, size: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text('$memberCount thành viên', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
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

