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
        .select('*, meals(*)')
        .eq('child_id', childId)
        .eq('meals.meal_date', dateString);

    // ملاحظة: قد تحتاج لتعديل استجابة Join حسب هيكل meal_selections_model
    return (response as List)
        .map((json) => MealSelectionModel.fromJson(json))
        .toList();
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

  /// الاستماع لوجبات اليوم (Real-time)
  Stream<List<MealModel>> watchTodayMeals() {
    final dateString = DateTime.now().toIso8601String().split('T').first;
    return _client
        .from('meals')
        .stream(primaryKey: ['id'])
        .eq('meal_date', dateString)
        .order('time')
        .map((data) => data.map((json) => MealModel.fromJson(json)).toList());
  }
}
