import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/data_providers.dart';
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

    if (teacher == null) return const SizedBox.shrink();

    final teacherId = teacher.id;

    return MultiProvider(
      providers: [
        DataProviders.childrenProvider(teacherId),
      ],
      child: _TeacherHomeView(
        searchController: _searchController,
        teacherId: teacherId,
      ),
    );
  }
}

class _TeacherHomeView extends StatelessWidget {
  final TextEditingController searchController;
  final String teacherId;

  const _TeacherHomeView({
    required this.searchController,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    final childrenAsync = context.watch<List<ChildModel>?>();
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isSmallScreen = screenWidth < 360;

    final padding = screenWidth * 0.04;
    final cardPadding = isSmallScreen ? 14.0 : 20.0;

    // Show loading state while children are being fetched
    if (childrenAsync == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('الرئيسية'),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final children = childrenAsync;

    // Filter children based on search
    final filteredChildren = children
        .where((child) => child.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            (context as Element).markNeedsBuild();
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
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: _buildQuickActionCard(
                      context, cardPadding, isSmallScreen),
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
                            searchController.text.isEmpty
                                ? 'لا يوجد أطفال مسجلين تحت إشرافك حالياً'
                                : 'لا يوجد نتائج للبحث عن "${searchController.text}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          if (searchController.text.isEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Trigger a rebuild and re-fetch
                                (context as Element).markNeedsBuild();
                              },
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
        ),
      ),
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
        controller: searchController,
        textDirection: TextDirection.rtl,
        onChanged: (_) {
          // Trigger rebuild to update filteredChildren
          (context as Element).markNeedsBuild();
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن طفل...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.search,
              color: AppColors.textSecondary, size: isSmallScreen ? 20 : 24),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: AppColors.textSecondary,
                      size: isSmallScreen ? 18 : 22),
                  onPressed: () {
                    searchController.clear();
                    (context as Element).markNeedsBuild();
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

  Widget _buildQuickActionCard(
      BuildContext context, double cardPadding, bool isSmallScreen) {
    return GestureDetector(
      onTap: () => context.push('/teacher/report'),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent,
              AppColors.accent.withOpacity(0.8),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
                size: isSmallScreen ? 26 : 32,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كتابة تقرير',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 20,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إنشاء تقرير يومي جديد',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: isSmallScreen ? 16 : 20,
            ),
          ],
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
