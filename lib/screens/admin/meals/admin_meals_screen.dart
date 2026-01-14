import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/models.dart';
import '../../../../repositories/meal_repository.dart';
import '../widgets/admin_drawer.dart';

class AdminMealsScreen extends StatefulWidget {
  const AdminMealsScreen({super.key});

  @override
  State<AdminMealsScreen> createState() => _AdminMealsScreenState();
}

class _AdminMealsScreenState extends State<AdminMealsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<MealModel> _todayMeals = [];
  List<MealModel> _allMeals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<MealRepository>();
      final results = await Future.wait([
        repo.getTodayMeals(),
        repo.getAllMeals(),
      ]);

      if (mounted) {
        setState(() {
          _todayMeals = results[0];
          _allMeals = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الوجبات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('إدارة الوجبات', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'وجبات اليوم'),
            Tab(text: 'كل الوجبات'),
          ],
        ),
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/admin/meals/add');
          _loadMeals();
        },
        label: const Text('إضافة وجبة'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMealsList(_todayMeals, isToday: true),
                _buildMealsList(_allMeals, isToday: false),
              ],
            ),
    );
  }

  Widget _buildMealsList(List<MealModel> meals, {required bool isToday}) {
    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isToday ? 'لا توجد وجبات اليوم' : 'لا توجد وجبات مسجلة',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getMealColor(meal.mealType).withOpacity(0.1),
                child: Icon(_getMealIcon(meal.mealType),
                    color: _getMealColor(meal.mealType)),
              ),
              title: Text(
                meal.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        meal.time,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      if (!isToday) ...[
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy-MM-dd').format(meal.mealDate),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.items.join('، '),
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              trailing: isToday
                  ? null // Today's meals might have actions later
                  : const Icon(Icons.history, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppColors.accent;
      case MealType.lunch:
        return AppColors.primary;
      case MealType.snack:
        return AppColors.secondary;
      case MealType.dinner:
        return Colors.purple;
    }
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.snack:
        return Icons.cookie;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }
}
