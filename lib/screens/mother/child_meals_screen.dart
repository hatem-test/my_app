import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/models.dart';
import '../../repositories/meal_repository.dart';
import '../../repositories/children_repository.dart';

class ChildMealsScreen extends StatefulWidget {
  final String childId;

  const ChildMealsScreen({super.key, required this.childId});

  @override
  State<ChildMealsScreen> createState() => _ChildMealsScreenState();
}

class _ChildMealsScreenState extends State<ChildMealsScreen> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealRepo = context.read<MealRepository>();
    final childrenRepo = context.read<ChildrenRepository>();
    final authProvider = context.read<AuthProvider>();
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isSmallScreen = width < 360;
    final padding = width * 0.04;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('وجبات الطفل'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<ChildModel?>(
        stream: childrenRepo.watchChild(widget.childId),
        builder: (context, childSnapshot) {
          final child = childSnapshot.data;
          final allergies = child?.allergies ?? [];

          return StreamBuilder<List<MealSelectionModel>>(
            stream: mealRepo.watchMealSelections(widget.childId, today),
            builder: (context, selectionsSnapshot) {
              final selectedMealIds =
                  selectionsSnapshot.data?.map((s) => s.mealId).toSet() ?? {};

              return FutureBuilder<List<MealModel>>(
                key: ValueKey(_refreshKey),
                future: mealRepo.getTodayMeals(),
                builder: (context, mealsSnapshot) {
                  if (mealsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (mealsSnapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              'حدث خطأ أثناء جلب الوجبات: ${mealsSnapshot.error}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final meals = mealsSnapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: () async {
                      // إعادة تحميل البيانات
                      _refresh();
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (allergies.isNotEmpty) ...[
                            _buildAllergyWarning(allergies, isSmallScreen),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                          ],
                          Text(
                            'وجبات اليوم',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          if (meals.isEmpty)
                            _buildEmptyState(isSmallScreen, padding)
                          else
                            ...meals.map((meal) => _buildMealCard(
                                  context,
                                  meal,
                                  isSmallScreen,
                                  widget.childId,
                                  selectedMealIds.contains(meal.id),
                                  authProvider.currentUser?.id,
                                  mealRepo,
                                )),
                          SizedBox(height: isSmallScreen ? 20 : 24),
                          const Divider(),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'كل الوجبات',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          FutureBuilder<List<MealModel>>(
                            key: const ValueKey('all_meals_\$_refreshKey'),
                            future: mealRepo.getAllMeals(),
                            builder: (context, allSnapshot) {
                              if (allSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (allSnapshot.hasError) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                                  child: Text(
                                    'حدث خطأ أثناء جلب كل الوجبات: ${allSnapshot.error}',
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                );
                              }

                              final allMeals = allSnapshot.data ?? [];
                              if (allMeals.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                                  child: const Text(
                                    'لا توجد وجبات مسجلة بعد',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                );
                              }

                              final dates = allMeals
                                  .map((m) => DateTime(m.mealDate.year, m.mealDate.month, m.mealDate.day))
                                  .toSet()
                                  .toList();
                              dates.sort((a, b) => b.compareTo(a)); // تنازلي حسب التاريخ

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final d in dates) ...[
                                    Text(
                                      '${d.year}-${d.month}-${d.day}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 10),
                                    for (final meal in (allMeals
                                        .where((m) => m.mealDate.year == d.year && m.mealDate.month == d.month && m.mealDate.day == d.day)
                                        .toList()..sort((a, b) => a.time.compareTo(b.time))))
                                      _buildMealCard(
                                        context,
                                        meal,
                                        isSmallScreen,
                                        widget.childId,
                                        false,
                                        null,
                                        mealRepo,
                                      ),
                                    SizedBox(height: isSmallScreen ? 12 : 16),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAllergyWarning(List<String> allergies, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: AppColors.warning.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: const Color(0xFFFF8F00),
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحذير من الحساسية',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF8F00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حساسية من: ${allergies.join('، ')}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen, double padding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant_outlined,
                  size: isSmallScreen ? 48 : 64, color: AppColors.textDisabled),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد وجبات متاحة اليوم',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم عرض الوجبات هنا عند إضافتها من قبل المعلمة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    MealModel meal,
    bool isSmallScreen,
    String childId,
    bool isSelected,
    String? userId,
    MealRepository mealRepo,
  ) {
    final iconData = _getMealIcon(meal.mealType);
    final color = _getMealColor(meal.mealType);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: isSelected
            ? Border.all(color: AppColors.success, width: 2)
            : Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 12 : 14),
                  ),
                  child: Icon(
                    iconData,
                    color: color,
                    size: isSmallScreen ? 22 : 26,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: isSmallScreen ? 14 : 16,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            meal.time,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            const Divider(height: 1),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meal.items.map((item) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 14,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (userId != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _toggleMealSelection(
                    context,
                    meal,
                    childId,
                    userId,
                    isSelected,
                    mealRepo,
                  ),
                  icon: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.close_rounded,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  label: Text(
                    isSelected ? 'إزالة الاختيار' : 'اختيار الوجبة',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.error : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(isSmallScreen ? 12 : 16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMealSelection(
    BuildContext context,
    MealModel meal,
    String childId,
    String userId,
    bool isSelected,
    MealRepository mealRepo,
  ) async {
    try {
      if (isSelected) {
        // إزالة الاختيار
        await mealRepo.unselectMeal(childId, meal.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إزالة ${meal.name} من الاختيار'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.error,
            ),
          );
          // إعادة تحميل البيانات
          _refresh();
        }
      } else {
        // إضافة الاختيار
        await mealRepo.selectMeal(childId, meal.id, userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار ${meal.name} بنجاح'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.success,
            ),
          );
          // إعادة تحميل البيانات
          _refresh();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر ${isSelected ? 'إزالة' : 'اختيار'} الوجبة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast_rounded;
      case MealType.snack:
        return Icons.cookie_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
    }
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppColors.accent;
      case MealType.snack:
        return AppColors.secondary;
      case MealType.lunch:
        return AppColors.primary;
      case MealType.dinner:
        return Colors.purple;
    }
  }
}
