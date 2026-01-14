import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class MealRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// جلب الوجبات المتاحة ليوم معين
  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    final dateString = date.toIso8601String().split('T').first;
    final response = await _client
        .from('meals')
        .select()
        .eq('meal_date', dateString)
        .order('time');
    return (response as List).map((json) => MealModel.fromJson(json)).toList();
  }

  /// جلب اختيارات الوجبات لطفل معين في يوم معين
  Future<List<MealSelectionModel>> getMealSelections(
      String childId, DateTime date) async {
    final dateString = date.toIso8601String().split('T').first;
    final response = await _client
        .from('meal_selections')
        .select('*, meals!inner(*)')
        .eq('child_id', childId)
        .eq('meals.meal_date', dateString);

    return (response as List)
        .map((json) => MealSelectionModel.fromJson(json))
        .toList();
  }

  /// الاستماع لاختيارات الوجبات لطفل معين (Real-time)
  Stream<List<MealSelectionModel>> watchMealSelections(
      String childId, DateTime date) {
    final dateString = date.toIso8601String().split('T').first;
    return _client
        .from('meal_selections')
        .stream(primaryKey: ['id'])
        .eq('child_id', childId)
        .asyncMap((data) async {
          // جلب بيانات الوجبات المرتبطة
          final selections =
              data.map((json) => MealSelectionModel.fromJson(json)).toList();
          final mealIds = selections.map((s) => s.mealId).toSet().toList();

          if (mealIds.isEmpty) return <MealSelectionModel>[];

          // جلب بيانات الوجبات
          final mealsResponse =
              await _client.from('meals').select().eq('meal_date', dateString);

          final allMeals = (mealsResponse as List)
              .map((json) => MealModel.fromJson(json))
              .toList();

          // تصفية الوجبات حسب mealIds
          final meals = allMeals.where((m) => mealIds.contains(m.id)).toList();

          // ربط الوجبات بالاختيارات
          final result = <MealSelectionModel>[];
          for (final selection in selections) {
            try {
              final meal = meals.firstWhere((m) => m.id == selection.mealId);
              if (meal.mealDate.toIso8601String().split('T').first ==
                  dateString) {
                result.add(selection.copyWith(meal: meal));
              }
            } catch (e) {
              // تجاهل الاختيارات التي لا تحتوي على وجبة صالحة
              continue;
            }
          }
          return result;
        });
  }

  /// إضافة وجبة جديدة (للمسؤول)
  Future<MealModel> createMeal(MealModel meal) async {
    final response = await _client
        .from('meals')
        .insert(meal.toInsertJson())
        .select()
        .single();
    return MealModel.fromJson(response);
  }

  /// تسجيل اختيار وجبة للطفل
  Future<void> selectMeal(String childId, String mealId, String userId) async {
    await _client.from('meal_selections').insert({
      'child_id': childId,
      'meal_id': mealId,
      'selected_by': userId,
    });
  }

  /// إلغاء اختيار وجبة للطفل
  Future<void> unselectMeal(String childId, String mealId) async {
    await _client
        .from('meal_selections')
        .delete()
        .eq('child_id', childId)
        .eq('meal_id', mealId);
  }

  /// جلب اختيار وجبة معينة
  Future<MealSelectionModel?> getMealSelection(
      String childId, String mealId) async {
    try {
      final response = await _client
          .from('meal_selections')
          .select()
          .eq('child_id', childId)
          .eq('meal_id', mealId)
          .maybeSingle();

      if (response == null) return null;
      return MealSelectionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// الاستماع لوجبات اليوم (Real-time)
  Stream<List<MealModel>> watchTodayMeals() {
    final dateString = DateTime.now().toIso8601String().split('T').first;
    return _client
        .from('meals')
        .stream(primaryKey: ['id'])
        .eq('meal_date', dateString)
        .order('time')
        .map((data) {
          try {
            return (data as List)
                .map((json) => MealModel.fromJson(json as Map<String, dynamic>))
                .toList();
          } catch (e) {
            return <MealModel>[];
          }
        });
  }

  /// جلب وجبات اليوم (بدون stream - للاستخدام عند الحاجة)
  Future<List<MealModel>> getTodayMeals() async {
    final dateString = DateTime.now().toIso8601String().split('T').first;
    try {
      final response = await _client
          .from('meals')
          .select()
          .eq('meal_date', dateString)
          .order('time');
      return (response as List)
          .map((json) => MealModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return <MealModel>[];
    }
  }

  /// جلب كل الوجبات مرتبة حسب التاريخ تنازليًا ثم بالوقت تصاعديًا
  Future<List<MealModel>> getAllMeals() async {
    try {
      final response = await _client
          .from('meals')
          .select()
          .order('meal_date', ascending: false)
          .order('time', ascending: true);
      return (response as List)
          .map((json) => MealModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return <MealModel>[];
    }
  }
}
