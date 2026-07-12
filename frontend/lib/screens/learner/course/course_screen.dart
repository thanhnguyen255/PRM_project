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

