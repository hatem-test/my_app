-- ============================================================
-- سياسات Row Level Security (RLS) الكاملة للمدير (Admin)
-- هذا الملف يحتوي على جميع السياسات المطلوبة للمدير
-- يجب تنفيذه بعد تنفيذ fix_rls_policies.sql
-- ============================================================

-- ============================================================
-- 1. سياسات جدول المستخدمين (users) - للسماح للمدير بقراءة جميع المستخدمين
-- هذا ضروري عند استخدام joins للحصول على أسماء المستخدمين
-- ============================================================
DROP POLICY IF EXISTS "Admins can view all users" ON users;
-- ملاحظة: تجنب الاستعلام على نفس جدول users داخل policy لتفادي الـ recursion
CREATE POLICY "Admins can view all users" ON users
FOR SELECT TO authenticated
USING (
  (auth.jwt() ->> 'role') = 'admin'
);

-- ============================================================
-- 2. سياسات جدول أولياء الأمور (guardians) - صلاحيات كاملة للمدير
-- هذا ضروري عند استخدام joins للحصول على بيانات ولي الأمر
-- ============================================================
DROP POLICY IF EXISTS "Admins can view all guardians" ON guardians;
CREATE POLICY "Admins can view all guardians" ON guardians
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can insert guardians" ON guardians;
CREATE POLICY "Admins can insert guardians" ON guardians
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can update guardians" ON guardians;
CREATE POLICY "Admins can update guardians" ON guardians
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can delete guardians" ON guardians;
CREATE POLICY "Admins can delete guardians" ON guardians
FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================
-- 3. سياسات جدول المعلمات (teachers) - صلاحيات كاملة للمدير
-- ============================================================
DROP POLICY IF EXISTS "Admins can insert teachers" ON teachers;
CREATE POLICY "Admins can insert teachers" ON teachers
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can update teachers" ON teachers;
CREATE POLICY "Admins can update teachers" ON teachers
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can delete teachers" ON teachers;
CREATE POLICY "Admins can delete teachers" ON teachers
FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================
-- 4. سياسات جدول الأطفال (children) - إضافة صلاحيات الإدراج والحذف للمدير
-- ============================================================
DROP POLICY IF EXISTS "Admins can insert children" ON children;
CREATE POLICY "Admins can insert children" ON children
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can delete children" ON children;
CREATE POLICY "Admins can delete children" ON children
FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================
-- ملاحظات مهمة:
-- ============================================================
-- 1. عند استخدام Supabase joins مثل:
--    SELECT *, guardians(id, users(name)), teachers(id, users(name))
--    FROM children
--    
--    يتم تطبيق RLS على كل جدول بشكل منفصل:
--    - children: يحتاج صلاحيات SELECT (موجودة ✅)
--    - guardians: يحتاج صلاحيات SELECT (أضفناها ✅)
--    - teachers: يحتاج صلاحيات SELECT (موجودة ✅)
--    - users: يحتاج صلاحيات SELECT (أضفناها ✅)
--
-- 2. للتحقق من أن السياسات تعمل بشكل صحيح:
--    - تأكد من أن المستخدم مسجل كـ admin في جدول users
--    - تأكد من أن role = 'admin' (وليس 'Admin' أو 'ADMIN')
--
-- 3. لتنفيذ هذا الملف في Supabase:
--    - اذهب إلى SQL Editor في Supabase Dashboard
--    - انسخ ولصق محتوى هذا الملف
--    - اضغط Run لتنفيذ جميع السياسات
-- ============================================================