-- ============================================================
-- سياسات Row Level Security (RLS) الإضافية للمدير (Admin)
-- هذه السياسات ضرورية لجلب البيانات مع Joins
-- ============================================================

-- ============================================================
-- 1. سياسات جدول المستخدمين (users) - للسماح للمدير بقراءة جميع المستخدمين
-- ============================================================
DROP POLICY IF EXISTS "Admins can view all users" ON users;
CREATE POLICY "Admins can view all users" ON users
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================
-- 2. سياسات جدول أولياء الأمور (guardians) - للسماح للمدير بقراءة جميع أولياء الأمور
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
-- 3. سياسات جدول المعلمات (teachers) - للتأكد من وجود صلاحيات كاملة للمدير
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
-- 4. سياسات جدول الأطفال (children) - إضافة صلاحيات الحذف للمدير
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
-- 1. هذه السياسات تضيف صلاحيات كاملة للمدير على جميع الجداول
-- 2. عند استخدام Supabase joins، يتم تطبيق RLS على كل جدول بشكل منفصل
-- 3. لذلك نحتاج إلى صلاحيات على:
--    - children (للقراءة والتحديث موجودة، أضفنا الحذف والإدراج)
--    - guardians (أضفنا جميع الصلاحيات)
--    - teachers (كانت القراءة موجودة، أضفنا باقي الصلاحيات)
--    - users (أضفنا القراءة للمدير ليعمل join بشكل صحيح)
-- ============================================================