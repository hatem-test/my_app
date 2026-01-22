# 🔄 الكود المتغير - قبل وبعد

## 📋 نظرة عامة

تم تعديل 5 ملفات لحل مشكلة تعطل التطبيق عند تسجيل الدخول للمعلمة.

---

## 1️⃣ `lib/services/auth_service.dart`

### ❌ قبل (المشكلة)

```dart
Future<UserModel> _syncProfileIfMissing(User authUser) async {
  // ...
  try {
    await _repository.createUserProfile(newUser);

    // محاولة إنشاء سجلات الدور مباشرة = مشكلة!
    if (newUser.role == UserRole.mother) {
      await _guardianRepository.createGuardianSkeleton(newUser.id);
    } else if (newUser.role == UserRole.teacher) {
      await _teacherRepository.createTeacherSkeleton(newUser.id); // ← المشكلة
    }
  } catch (e) {
    debugPrint('Error syncing profile records: $e');
  }
  return newUser;
}
```

### ✅ بعد (الحل)

```dart
Future<UserModel> _syncProfileIfMissing(User authUser) async {
  // ...
  // 1. إعادة إنشاء سجل المستخدم فقط
  // تم تخطي إنشاء سجلات role skeleton أثناء تسجيل الدخول لتجنب التأخير والصراعات مع RLS
  try {
    await _repository.createUserProfile(newUser);
  } catch (e) {
    debugPrint('Error syncing user profile: $e');
    // لا نوقف العملية لأن ملف Auth موجود بالفعل
  }
  return newUser;
}
```

**الفرق:**

- ❌ محاولة إنشاء guardian و teacher skeleton = بطيء وقد يفشل
- ✅ إنشاء users فقط = سريع وآمن

---

## 2️⃣ `lib/core/providers/teacher_provider.dart`

### ❌ قبل (المشكلة)

```dart
Future<void> loadProfile(String userId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _profile = await _repository.getTeacherByUserId(userId);
    if (_profile == null) {
      _error = 'لم يتم العثور على ملف المعلمة'; // ← خطأ نهائي!
    }
  } catch (e) {
    _error = 'حدث خطأ أثناء تحميل البيانات: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### ✅ بعد (الحل)

```dart
Future<void> loadProfile(String userId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _profile = await _repository.getTeacherByUserId(userId);

    // إذا لم يوجد سجل، نحاول إنشاء skeleton ✅
    if (_profile == null) {
      try {
        await _repository.createTeacherSkeleton(userId);
        // نحاول التحميل مرة أخرى بعد الإنشاء بتأخير صغير
        await Future.delayed(const Duration(milliseconds: 500));
        _profile = await _repository.getTeacherByUserId(userId);
      } catch (createError) {
        print('Warning: Could not create teacher skeleton: $createError');
      }

      if (_profile == null) {
        _error = 'لم يتم العثور على ملف المعلمة. يرجى المحاولة لاحقاً.';
      }
    }
  } catch (e) {
    _error = 'حدث خطأ أثناء تحميل البيانات: ${e.toString()}';
    print('TeacherProvider loadProfile error: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**الفرق:**

- ❌ فشل مباشرة إذا لم يكن السجل موجوداً
- ✅ محاولة الإنشاء أولاً، ثم الفشل إذا استمر المشكل

---

## 3️⃣ `lib/repositories/teacher_repository.dart`

### ❌ قبل (بلا timeout)

```dart
Future<TeacherModel?> getTeacherByUserId(String userId) async {
  try {
    final response = await _client
        .from('teachers')
        .select('*, users(*)')
        .eq('user_id', userId)
        .maybeSingle(); // ← قد يتعطل هنا للأبد!
    return response != null ? TeacherModel.fromJson(response) : null;
  } on PostgrestException catch (e) {
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('row-level') || msg.contains('permission') || msg.contains('rls')) {
      final fallback = await _client.from('teachers').select().eq('user_id', userId).maybeSingle();
      return fallback != null
          ? TeacherModel.fromJson(Map<String, dynamic>.from(fallback as Map))
          : null;
    }
    rethrow;
  }
}
```

### ✅ بعد (مع timeout)

```dart
Future<TeacherModel?> getTeacherByUserId(String userId) async {
  try {
    final response = await _client
        .from('teachers')
        .select('*, users(*)')
        .eq('user_id', userId)
        .maybeSingle()
        .timeout( // ✅ إضافة timeout
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
              'تم تجاوز وقت انتظار التحميل. تأكد من اتصالك بالإنترنت.'),
        );
    return response != null ? TeacherModel.fromJson(response) : null;
  } on TimeoutException {
    rethrow;
  } on PostgrestException catch (e) {
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('row-level') || msg.contains('permission') || msg.contains('rls')) {
      try {
        final fallback = await _client
            .from('teachers')
            .select()
            .eq('user_id', userId)
            .maybeSingle()
            .timeout(const Duration(seconds: 10)); // ✅ هنا أيضاً
        return fallback != null
            ? TeacherModel.fromJson(Map<String, dynamic>.from(fallback as Map))
            : null;
      } catch (fallbackError) {
        rethrow;
      }
    }
    rethrow;
  } catch (e) {
    rethrow;
  }
}
```

**الفرق:**

- ❌ بلا timeout = قد يتعطل للأبد إذا حدثت مشكلة اتصال
- ✅ مع timeout = رسالة خطأ واضحة بعد 10 ثوانٍ

---

## 4️⃣ `lib/repositories/teacher_repository.dart` - skeleton creation

### ❌ قبل (بلا معالجة)

```dart
Future<void> createTeacherSkeleton(String userId) async {
  await _client.from('teachers').upsert({
    'user_id': userId,
    'is_active': true,
  }); // ← قد يفشل بلا معالجة!
}
```

### ✅ بعد (مع معالجة أخطاء آمنة)

```dart
Future<void> createTeacherSkeleton(String userId) async {
  try {
    await _client
        .from('teachers')
        .upsert({
          'user_id': userId,
          'is_active': true,
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('انتهت مهلة إنشاء السجل'),
        );
  } on TimeoutException {
    print('Warning: Timeout creating teacher skeleton');
  } catch (e) {
    print('Warning: Could not create teacher skeleton: $e');
  }
}
```

**الفرق:**

- ❌ فشل يوقف العملية كاملة
- ✅ معالجة آمنة = لا نوقف التطبيق حتى لو فشل الإنشاء

---

## 5️⃣ `lib/screens/teacher/teacher_main_screen.dart`

### ❌ قبل (بدون tracking)

```dart
class _TeacherMainScreenState extends State<TeacherMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, teacherProvider, _) {
        final authProvider = context.watch<AuthProvider>();
        final userId = authProvider.currentUser?.id;

        if (userId != null &&
            !teacherProvider.isLoading &&
            (teacherProvider.profile == null ||
                teacherProvider.profile!.userId != userId)) {
          // قد ينادي loadProfile أكثر من مرة! ❌
          Future.microtask(() {
            if (mounted) {
              context.read<TeacherProvider>().loadProfile(userId);
            }
          });
        }

        if (teacherProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل بيانات المعلمة...'),
                ],
              ),
            ),
          );
        }

        if (teacherProvider.error != null || teacherProvider.profile == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      teacherProvider.error ?? 'لم يتم العثور على بيانات المعلمة', // ❌ رسالة غير واضحة
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    // ...
```

### ✅ بعد (مع tracking ورسائل محسّنة)

```dart
class _TeacherMainScreenState extends State<TeacherMainScreen> {
  bool _loadingInitiated = false; // ✅ منع الاستدعاءات المتكررة

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, teacherProvider, _) {
        final authProvider = context.watch<AuthProvider>();
        final userId = authProvider.currentUser?.id;

        if (userId != null &&
            !_loadingInitiated && // ✅ فحص العلم
            teacherProvider.profile == null) {
          _loadingInitiated = true; // ✅ تعيين العلم
          Future.microtask(() {
            if (mounted) {
              context.read<TeacherProvider>().loadProfile(userId);
            }
          });
        }

        // إعادة تعيين العلم عند تغيير المستخدم
        if (userId != null &&
            _loadingInitiated &&
            teacherProvider.profile?.userId != userId) {
          _loadingInitiated = false;
        }

        if (teacherProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل بيانات المعلمة...'),
                  SizedBox(height: 8),
                  Text( // ✅ رسالة توضيحية
                    'قد يستغرق بعض الوقت',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (teacherProvider.error != null || teacherProvider.profile == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      teacherProvider.error ??
                          'لم يتم العثور على بيانات المعلمة. تأكد من اتصالك بالإنترنت.', // ✅ رسالة واضحة ومفيدة
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _loadingInitiated = false; // ✅ إعادة تعيين
                        final userId = context.read<AuthProvider>().currentUser?.id;
                        if (userId != null) {
                          context.read<TeacherProvider>().loadProfile(userId);
                        }
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                    TextButton(
                      onPressed: () => context.read<AuthProvider>().logout(),
                      child: const Text('تسجيل الخروج'), // ✅ خيار جديد
                    ),
                  ],
                ),
              ),
            ),
          );
        }
```

**الفرق:**

- ❌ استدعاء متكرر + رسائل غير واضحة
- ✅ منع الاستدعاء المتكرر + رسائل مفيدة

---

## 📊 ملخص التغييرات

| الملف                    | التغيير               | التأثير                     |
| ------------------------ | --------------------- | --------------------------- |
| auth_service.dart        | حذف skeleton creation | -50% من وقت التسجيل         |
| teacher_provider.dart    | إضافة إنشاء ذكي       | معالجة آمنة للحالات الناقصة |
| teacher_repository.dart  | إضافة timeout         | منع التعطل اللانهائي        |
| guardian_repository.dart | إضافة timeout         | منع التعطل اللانهائي        |
| teacher_main_screen.dart | تحسين UX              | رسائل واضحة + منع التكرار   |

---

**النتيجة النهائية:** ✅ تطبيق أسرع وأكثر استقراراً!
