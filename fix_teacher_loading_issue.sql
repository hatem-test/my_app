-- إصلاح مشكلة تعطل تطبيق المعلمة عند تسجيل الدخول
-- المشكلة: السياسات تتطلب سجل في جدول teachers لقراءة البيانات
-- الحل: السماح بالقراءة حسب auth.uid() مباشرة دون الاعتماد على وجود صف في users

-- تحديث سياسات جدول المعلمات (teachers)
DROP POLICY IF EXISTS "Allow teachers to read their own record" ON teachers;
CREATE POLICY "Allow teachers to read their own record" ON teachers
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- السماح بإدراج سجل معلمة دون الحاجة لوجود سجل في users
DROP POLICY IF EXISTS "Allow teachers to insert their own record" ON teachers;
CREATE POLICY "Allow teachers to insert their own record" ON teachers
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- تحديث سياسات جدول أولياء الأمور (guardians)
DROP POLICY IF EXISTS "Allow guardians to read their own record" ON guardians;
CREATE POLICY "Allow guardians to read their own record" ON guardians
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- السماح بإدراج سجل ولي أمر دون الحاجة لوجود سجل في users
DROP POLICY IF EXISTS "Allow guardians to insert their own record" ON guardians;
CREATE POLICY "Allow guardians to insert their own record" ON guardians
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- إضافة سياسة للسماح لأي مستخدم مصرح بقراءة سجلات المعلمات والأمور من خلال JWT role
DROP POLICY IF EXISTS "Allow role-based access via JWT" ON teachers;
CREATE POLICY "Allow role-based access via JWT" ON teachers
FOR SELECT TO authenticated
USING (
  auth.uid() = user_id OR
  (auth.jwt() ->> 'role') = 'admin'
);

DROP POLICY IF EXISTS "Allow role-based access via JWT" ON guardians;
CREATE POLICY "Allow role-based access via JWT" ON guardians
FOR SELECT TO authenticated
USING (
  auth.uid() = user_id OR
  (auth.jwt() ->> 'role') = 'admin'
);
