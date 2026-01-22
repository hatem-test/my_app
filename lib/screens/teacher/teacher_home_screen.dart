import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../repositories/children_repository.dart';
import '../../core/providers/teacher_provider.dart';
import '../../models/models.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم ملف المعلمة من الـ TeacherProvider العالمي
    final teacherProvider = context.watch<TeacherProvider>();
    final teacher = teacherProvider.profile;

    debugPrint(
        'DEBUG: TeacherHomeScreen - Teacher: ${teacher?.id} - ${teacher?.name}');

    if (teacher == null) {
      debugPrint('DEBUG: TeacherHomeScreen - Teacher is null!');
      return const SizedBox.shrink();
    }

    final teacherId = teacher.id;
    debugPrint('DEBUG: TeacherHomeScreen - Using teacherId: $teacherId');

    return _TeacherHomeView(
      searchController: _searchController,
      teacherId: teacherId,
    );
  }
}

class _TeacherHomeView extends StatefulWidget {
  final TextEditingController searchController;
  final String teacherId;

  const _TeacherHomeView({
    required this.searchController,
    required this.teacherId,
  });

  @override
  State<_TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<_TeacherHomeView> {
  late Future<List<ChildModel>?> _childrenFuture;

  @override
  void initState() {
    super.initState();
    // تخزين الـ future مرة واحدة فقط في initState
    _childrenFuture = context
        .read<ChildrenRepository>()
        .getChildrenByTeacher(widget.teacherId);
  }

  void _refreshChildren() {
    setState(() {
      _childrenFuture = context
          .read<ChildrenRepository>()
          .getChildrenByTeacher(widget.teacherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: TeacherHomeView build called');

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isSmallScreen = screenWidth < 360;

    final padding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildChildrenList(
          context,
          widget.teacherId,
          padding,
          isSmallScreen,
          screenHeight,
        ),
      ),
    );
  }

  Widget _buildChildrenList(
    BuildContext context,
    String teacherId,
    double padding,
    bool isSmallScreen,
    double screenHeight,
  ) {
    return FutureBuilder<List<ChildModel>?>(
      future: _childrenFuture,
      builder: (context, snapshot) {
        debugPrint(
            'DEBUG: FutureBuilder connectionState: ${snapshot.connectionState}');
        debugPrint('DEBUG: FutureBuilder data: ${snapshot.data}');
        debugPrint('DEBUG: FutureBuilder error: ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text('حدث خطأ: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshChildren,
                  child: const Text('محاولة مجددا'),
                ),
              ],
            ),
          );
        }

        final children = snapshot.data ?? [];
        debugPrint('DEBUG: Received ${children.length} children');

        // Filter children based on search
        final filteredChildren = children
            .where((child) => child.name
                .toLowerCase()
                .contains(widget.searchController.text.toLowerCase()))
            .toList();

        debugPrint('DEBUG: After filter: ${filteredChildren.length} children');

        return RefreshIndicator(
          onRefresh: () async {
            _refreshChildren();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: _buildSearchField(context, isSmallScreen),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Text(
                    'قائمة الأطفال',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: isSmallScreen ? 18 : 20,
                        ),
                  ),
                ),
              ),
              if (filteredChildren.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.searchController.text.isEmpty
                                ? 'لا يوجد أطفال مسجلين تحت إشرافك حالياً'
                                : 'لا يوجد نتائج للبحث عن "${widget.searchController.text}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          if (widget.searchController.text.isEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _refreshChildren,
                              icon: const Icon(Icons.refresh),
                              label: const Text('تحديث القائمة'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildChildCard(
                          context, filteredChildren[index], isSmallScreen),
                      childCount: filteredChildren.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: screenHeight * 0.03)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.searchController,
        textDirection: TextDirection.rtl,
        onChanged: (_) {
          // Trigger rebuild to update filteredChildren
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن طفل...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.search,
              color: AppColors.textSecondary, size: isSmallScreen ? 20 : 24),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: AppColors.textSecondary,
                      size: isSmallScreen ? 18 : 22),
                  onPressed: () {
                    widget.searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 14 : 20,
            vertical: isSmallScreen ? 12 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(
      BuildContext context, ChildModel child, bool isSmallScreen) {
    final bool isBoy = child.gender == Gender.boy;
    final String imagePath = child.imageUrl ?? child.defaultImagePath;

    return GestureDetector(
      onTap: () => context.push('/teacher/child/${child.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar on the right (RTL)
            CircleAvatar(
              radius: isSmallScreen ? 22 : 26,
              backgroundColor: isBoy
                  ? AppColors.primary.withOpacity(0.1)
                  : const Color(0xFFFCE4EC),
              backgroundImage: imagePath.startsWith('assets')
                  ? AssetImage(imagePath) as ImageProvider
                  : NetworkImage(imagePath),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),

            // Name in the center
            Expanded(
              child: Text(
                child.name,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Chevron arrow on the left (RTL)
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: isSmallScreen ? 22 : 26,
            ),
          ],
        ),
      ),
    );
  }
}
