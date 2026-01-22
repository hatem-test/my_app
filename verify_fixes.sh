#!/bin/bash
# اختبار سريع للتحقق من الإصلاح

echo "🔍 اختبار شامل لمشكلة تعطل تطبيق المعلمة"
echo "=========================================="

# الخطوة 1: التحقق من الملفات المعدلة
echo ""
echo "✅ التحقق من الملفات..."

files=(
  "lib/services/auth_service.dart"
  "lib/core/providers/teacher_provider.dart"
  "lib/repositories/teacher_repository.dart"
  "lib/repositories/guardian_repository.dart"
  "lib/screens/teacher/teacher_main_screen.dart"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ✗ $file (مفقود!)"
  fi
done

# الخطوة 2: التحقق من وجود timeout
echo ""
echo "✅ التحقق من وجود معالجة Timeout..."

if grep -q "timeout(" lib/repositories/teacher_repository.dart; then
  echo "  ✓ Teacher repository يحتوي على timeout"
else
  echo "  ✗ Teacher repository لا يحتوي على timeout"
fi

if grep -q "timeout(" lib/repositories/guardian_repository.dart; then
  echo "  ✓ Guardian repository يحتوي على timeout"
else
  echo "  ✗ Guardian repository لا يحتوي على timeout"
fi

# الخطوة 3: التحقق من وجود createTeacherSkeleton
echo ""
echo "✅ التحقق من وجود createTeacherSkeleton..."

if grep -q "createTeacherSkeleton" lib/core/providers/teacher_provider.dart; then
  echo "  ✓ TeacherProvider يستخدم createTeacherSkeleton"
else
  echo "  ✗ TeacherProvider لا يستخدم createTeacherSkeleton"
fi

# الخطوة 4: التحقق من رسائل خطأ محسّنة
echo ""
echo "✅ التحقق من رسائل الخطأ المحسّنة..."

if grep -q "تأكد من اتصالك بالإنترنت" lib/screens/teacher/teacher_main_screen.dart; then
  echo "  ✓ تم تحسين رسائل الخطأ"
else
  echo "  ✗ رسائل الخطأ لم تتم تحسينها"
fi

# الخطوة 5: الملفات الإرشادية
echo ""
echo "✅ التحقق من ملفات التوثيق..."

docs=(
  "FIXES_SUMMARY.md"
  "VERIFICATION_GUIDE.md"
  "TEACHER_LOGIN_FIX.md"
  "fix_teacher_loading_issue.sql"
)

for doc in "${docs[@]}"; do
  if [ -f "$doc" ]; then
    echo "  ✓ $doc"
  else
    echo "  ✗ $doc (مفقود!)"
  fi
done

# الخطوة 6: ملخص
echo ""
echo "=========================================="
echo "✅ التحقق اكتمل!"
echo ""
echo "الخطوات التالية:"
echo "1. شغّل fix_teacher_loading_issue.sql في Supabase"
echo "2. اختبر تسجيل الدخول كمعلمة جديدة"
echo "3. تأكد من الانتقال للشاشة الرئيسية خلال 5 ثوان"
echo ""
echo "📚 للمزيد من المعلومات، اقرأ FIXES_SUMMARY.md"

