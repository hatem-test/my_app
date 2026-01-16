import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../repositories/meal_repository.dart';
import '../../repositories/children_repository.dart';

class MealsScreen extends StatefulWidget {
  final String? childId;

  const MealsScreen({super.key, this.childId});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  String _formatHeadingDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return 'وجبات ${date.year} ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final mealRepo = context.read<MealRepository>();
    final childrenRepo = context.read<ChildrenRepository>();
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth * 0.04;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('الوجبات'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddMealDialog(context),
            tooltip: 'إضافة وجبة جديدة',
          ),
        ],
      ),
      body: widget.childId == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'يجب تحديد طفل لعرض الوجبات',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
            : StreamBuilder<ChildModel?>(
              stream: childrenRepo.watchChild(widget.childId!),
              builder: (context, childSnapshot) {
                final child = childSnapshot.data;
                final allergies = child?.allergies ?? [];

                return DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(text: 'الوجبات المختارة'),
                          Tab(text: 'وجبات اليوم'),
                          Tab(text: 'كل الوجبات'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // قسم الوجبات المختارة (unchanged)
                            StreamBuilder<List<MealSelectionModel>>(
                              stream: mealRepo.watchMealSelections(widget.childId!, today),
                              builder: (context, selectionsSnapshot) {
                                if (selectionsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (selectionsSnapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error_outline,
                                              size: 64, color: AppColors.error),
                                          const SizedBox(height: 16),
                                          Text(
                                            'حدث خطأ أثناء جلب الوجبات المختارة',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 16 : 18,
                                              color: AppColors.textPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final selections = selectionsSnapshot.data ?? [];
                                final selectedMeals = selections
                                    .where((s) => s.meal != null)
                                    .map((s) => s.meal!)
                                    .toList();

                                return RefreshIndicator(
                                  onRefresh: () async {},
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(padding),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (allergies.isNotEmpty) ...[
                                          _buildAllergyWarning(
                                              allergies, isSmallScreen),
                                          SizedBox(
                                              height: isSmallScreen ? 16 : 20),
                                        ],
                                        Text(
                                          'الوجبات المختارة لـ ${child?.name ?? 'الطفل'}',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 18 : 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 16),
                                        if (selectedMeals.isEmpty)
                                          _buildEmptySelectedState(
                                              isSmallScreen, padding)
                                        else
                                          ...selectedMeals.map((meal) =>
                                              _buildMealCard(
                                                  meal, isSmallScreen)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // قسم وجبات اليوم (stream for live updates)
                            StreamBuilder<List<MealModel>>(
                              stream: mealRepo.watchTodayMeals(),
                              builder: (context, mealsSnapshot) {
                                if (mealsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (mealsSnapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error_outline,
                                              size: 64, color: AppColors.error),
                                          const SizedBox(height: 16),
                                          Text(
                                            'حدث خطأ أثناء جلب وجبات اليوم: ${mealsSnapshot.error}',
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
                                    // For stream-based tab, trigger a manual refresh by
                                    // bumping the local key (server push should handle it usually).
                                    _refresh();
                                  },
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(padding),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (allergies.isNotEmpty) ...[
                                          _buildAllergyWarning(
                                              allergies, isSmallScreen),
                                          SizedBox(
                                              height: isSmallScreen ? 16 : 20),
                                        ],
                                        Text(
                                          'وجبات اليوم',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontSize:
                                                    isSmallScreen ? 18 : 20,
                                              ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 16),
                                        if (meals.isEmpty)
                                          _buildEmptyState(isSmallScreen, padding)
                                        else
                                          ...meals.map((meal) =>
                                              _buildMealCard(meal, isSmallScreen)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // قسم كل الوجبات - grouped by date
                            FutureBuilder<List<MealModel>>(
                              key: ValueKey(_refreshKey),
                              future: mealRepo.getAllMeals(),
                              builder: (context, mealsSnapshot) {
                                if (mealsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (mealsSnapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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

                                if (meals.isEmpty) {
                                  return _buildEmptyState(isSmallScreen, padding);
                                }

                                // Group meals by date string
                                final groups = <String, List<MealModel>>{};
                                for (final meal in meals) {
                                  final dateKey = meal.mealDate
                                      .toIso8601String()
                                      .split('T')
                                      .first;
                                  groups.putIfAbsent(dateKey, () => []).add(meal);
                                }

                                // Sort dates descending
                                final dateKeys = groups.keys.toList()
                                  ..sort((a, b) => b.compareTo(a));

                                return RefreshIndicator(
                                  onRefresh: () async => _refresh(),
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(padding),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (final dateKey in dateKeys) ...[
                                          SizedBox(height: isSmallScreen ? 12 : 16),
                                          Text(
                                            _formatHeadingDate(
                                                DateTime.parse(dateKey)),
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: isSmallScreen ? 8 : 12),
                                          ...groups[dateKey]!
                                              .map((meal) => _buildMealCard(
                                                  meal, isSmallScreen)),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddMealDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMealDialog(
        isSmallScreen: isSmallScreen,
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
              'اضغط على زر الإضافة لإضافة وجبة جديدة',
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

  Widget _buildEmptySelectedState(bool isSmallScreen, double padding) {
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
              child: Icon(Icons.check_circle_outline,
                  size: isSmallScreen ? 48 : 64, color: AppColors.textDisabled),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد وجبات مختارة',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم اختيار أي وجبات لهذا الطفل بعد',
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

  Widget _buildMealCard(MealModel meal, bool isSmallScreen) {
    final iconData = _getMealIcon(meal.mealType);
    final color = _getMealColor(meal.mealType);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
          ],
        ),
      ),
    );
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

class _AddMealDialog extends StatefulWidget {
  final bool isSmallScreen;

  const _AddMealDialog({required this.isSmallScreen});

  @override
  State<_AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<_AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _itemController = TextEditingController();
  MealType _selectedType = MealType.lunch;
  DateTime _selectedDate = DateTime.now();
  final List<String> _items = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.isSmallScreen ? 24 : 28),
        ),
      ),
      padding: EdgeInsets.all(widget.isSmallScreen ? 20 : 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'إضافة وجبة جديدة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: widget.isSmallScreen ? 18 : 20,
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الوجبة',
                  prefixIcon: Icon(Icons.restaurant_rounded),
                  hintText: 'مثال: وجبة الغداء',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'يرجى إدخال اسم الوجبة' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'الوقت',
                  prefixIcon: Icon(Icons.access_time_rounded),
                  hintText: 'مثال: 12:30',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'يرجى إدخال الوقت' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MealType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع الوجبة',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: MealType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الوجبة',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'عناصر الوجبة',
                style: TextStyle(
                  fontSize: widget.isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                        hintText: 'أدخل عنصر الوجبة',
                        prefixIcon: Icon(Icons.fastfood_rounded),
                      ),
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _addItem(value.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppColors.primary,
                    onPressed: () {
                      if (_itemController.text.trim().isNotEmpty) {
                        _addItem(_itemController.text.trim());
                      }
                    },
                  ),
                ],
              ),
              if (_items.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'لا توجد عناصر. أضف عناصر الوجبة أعلاه.',
                  style: TextStyle(
                    fontSize: widget.isSmallScreen ? 12 : 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _items.map((item) {
                    return Chip(
                      label: Text(item),
                      onDeleted: () => _removeItem(item),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: widget.isSmallScreen ? 48 : 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? SizedBox(
                          width: widget.isSmallScreen ? 20 : 24,
                          height: widget.isSmallScreen ? 20 : 24,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إضافة الوجبة'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeText(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'الفطور';
      case MealType.snack:
        return 'وجبة خفيفة';
      case MealType.lunch:
        return 'الغداء';
      case MealType.dinner:
        return 'العشاء';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatHeadingDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    // Format: وجبات YYYY MONTH DAY
    return 'وجبات ${date.year} ${months[date.month - 1]} ${date.day}';
  }

  void _addItem(String item) {
    if (item.isNotEmpty && !_items.contains(item)) {
      setState(() {
        _items.add(item);
        _itemController.clear();
      });
    }
  }

  void _removeItem(String item) {
    setState(() {
      _items.remove(item);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة عنصر واحد على الأقل للوجبة')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final mealRepo = context.read<MealRepository>();
      final meal = MealModel(
        id: '',
        name: _nameController.text.trim(),
        time: _timeController.text.trim(),
        items: _items,
        mealType: _selectedType,
        mealDate: _selectedDate,
      );

      await mealRepo.createMeal(meal);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الوجبة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر إضافة الوجبة: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
