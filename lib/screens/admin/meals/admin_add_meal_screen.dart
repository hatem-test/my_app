import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/models.dart';
import '../../../../repositories/meal_repository.dart';

class AdminAddMealScreen extends StatefulWidget {
  const AdminAddMealScreen({super.key});

  @override
  State<AdminAddMealScreen> createState() => _AdminAddMealScreenState();
}

class _AdminAddMealScreenState extends State<AdminAddMealScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _itemController = TextEditingController();

  // State
  MealType _selectedType = MealType.lunch;
  DateTime _selectedDate = DateTime.now();
  List<String> _items = [];
  bool _isSubmitting = false;

  // Historical Data
  List<MealModel> _historyMeals = [];
  bool _isLoadingHistory = false;
  MealModel? _selectedHistoryMeal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();

    // Set default time to roughly next meal time
    final now = TimeOfDay.now();
    _timeController.text =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final repo = context.read<MealRepository>();
      final allMeals = await repo.getAllMeals();

      // Deduplicate by name + items to show unique meal types
      final uniqueMeals = <String, MealModel>{};
      for (var meal in allMeals) {
        final key = '${meal.name}-${meal.items.join(',')}';
        if (!uniqueMeals.containsKey(key)) {
          uniqueMeals[key] = meal;
        }
      }

      if (mounted) {
        setState(() {
          _historyMeals = uniqueMeals.values.toList();
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _timeController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _fillFormFromHistory(MealModel meal) {
    setState(() {
      _selectedHistoryMeal = meal;
      _nameController.text = meal.name;
      _items = List.from(meal.items);
      _selectedType = meal.mealType;
      // Keep current date

      // Switch to "New Meal" tab to edit details
      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم نسخ تفاصيل الوجبة، يرجى تحديد التاريخ والوقت')),
      );
    });
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إضافة عنصر واحد على الاقل للوجبة'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<MealRepository>();

      final newMeal = MealModel(
        id: const Uuid()
            .v4(), // Client-side ID or let DB handle it? Repository uses insert returning * so ID optional ideally but model requires it.
        // Wait, repository createMeal uses .select().single() and returns new model.
        // But the input to createMeal is MealModel which requires ID.
        // Usually we pass empty ID or use a specific CreateDTO.
        // Current MealModel requires ID. Let's start with a temp ID, the Repo might ignore it or we should fix Repo.
        // Based on MealRepository.createMeal: it calls INSERT with meal.toInsertJson().
        // toInsertJson() does NOT include ID. So the ID passed here doesn't matter for insertion.
        name: _nameController.text.trim(),
        time: _timeController.text.trim(),
        items: _items,
        mealType: _selectedType,
        mealDate: _selectedDate,
      );

      await repo.createMeal(newMeal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إضافة الوجبة بنجاح'),
              backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ أثناء الحفظ: $e'),
              backgroundColor: AppColors.error),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('إضافة وجبة', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'وجبة جديدة'),
            Tab(text: 'من السجل (تكرار)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewMealForm(),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildNewMealForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300)),
              child: ListTile(
                leading:
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                title: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('تاريخ الوجبة'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Basic Info
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الوجبة',
                hintText: 'مثال: وجبة غداء صحية',
                prefixIcon: Icon(Icons.restaurant),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MealType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'النوع',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: MealType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.mealTypeText),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'وقت التقديم',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        if (mounted) {
                          _timeController.text = time.format(
                              context); // Can format properly 24h/12h later
                          // For simplified storage, we might want 24h format manually
                          final h = time.hour.toString().padLeft(2, '0');
                          final m = time.minute.toString().padLeft(2, '0');
                          _timeController.text = '$h:$m';
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Items Section
            const Text('مكونات الوجبة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      hintText: 'أضف مكون (مثال: أرز، دجاج...)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() {
                          _items.add(v.trim());
                          _itemController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final v = _itemController.text.trim();
                    if (v.isNotEmpty) {
                      setState(() {
                        _items.add(v);
                        _itemController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _items
                  .map((item) => Chip(
                        label: Text(item),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => _items.remove(item)),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _saveMeal,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(_isSubmitting ? 'جاري الحفظ...' : 'حفظ الوجبة'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoadingHistory)
      return const Center(child: CircularProgressIndicator());
    if (_historyMeals.isEmpty)
      return const Center(child: Text('لا يوجد سجل وجبات سابق'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyMeals.length,
      itemBuilder: (context, index) {
        final meal = _historyMeals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.history, color: Colors.grey),
            ),
            title: Text(meal.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(meal.items.join('، '),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => _fillFormFromHistory(meal),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
} // Extention to support mealTypeText

extension MealTypeExt on MealType {
  String get mealTypeText {
    switch (this) {
      case MealType.breakfast:
        return 'فطور';
      case MealType.snack:
        return 'وجبة خفيفة';
      case MealType.lunch:
        return 'غداء';
      case MealType.dinner:
        return 'عشاء';
    }
  }
}
