import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data for children with gender
  final List<Map<String, dynamic>> _children = [
    {'id': '1', 'name': 'أحمد محمد', 'gender': 'boy'},
    {'id': '2', 'name': 'فاطمة علي', 'gender': 'girl'},
    {'id': '3', 'name': 'يوسف خالد', 'gender': 'boy'},
    {'id': '4', 'name': 'مريم سعيد', 'gender': 'girl'},
    {'id': '5', 'name': 'عمر حسن', 'gender': 'boy'},
    {'id': '6', 'name': 'نور أحمد', 'gender': 'girl'},
  ];

  List<Map<String, dynamic>> get _filteredChildren {
    if (_searchController.text.isEmpty) return _children;
    return _children
        .where((child) => child['name']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isSmallScreen = screenWidth < 360;

    // Responsive values
    final padding = screenWidth * 0.04;
    final cardPadding = isSmallScreen ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: _buildSearchField(isSmallScreen),
              ),
            ),

            // Quick Action Card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child:
                    _buildQuickActionCard(context, cardPadding, isSmallScreen),
              ),
            ),

            // Section Title
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

            // Children List (horizontal cards)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildChildCard(_filteredChildren[index], isSmallScreen),
                  childCount: _filteredChildren.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: screenHeight * 0.03)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'ابحث عن طفل...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.search,
              color: AppColors.textSecondary, size: isSmallScreen ? 20 : 24),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: AppColors.textSecondary,
                      size: isSmallScreen ? 18 : 22),
                  onPressed: () {
                    _searchController.clear();
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
                          color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildChildCard(Map<String, dynamic> child, bool isSmallScreen) {
    final bool isBoy = child['gender'] == 'boy';
    final String imagePath =
        isBoy ? 'assets/images/boy.png' : 'assets/images/girl.png';

    return GestureDetector(
      onTap: () => context.push('/teacher/child/${child['id']}'),
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
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : const Color(0xFFFCE4EC),
              backgroundImage: AssetImage(imagePath),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),

            // Name in the center
            Expanded(
              child: Text(
                child['name'],
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
