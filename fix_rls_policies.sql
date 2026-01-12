-- سياسات جدول المستخدمين (users)
DROP POLICY IF EXISTS "Allow users to read their own profile" ON users;
CREATE POLICY "Allow users to read their own profile" ON users
FOR SELECT TO authenticated
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Allow users to insert their own profile" ON users;
CREATE POLICY "Allow users to insert their own profile" ON users
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Allow users to update their own profile" ON users;
CREATE POLICY "Allow users to update their own profile" ON users
FOR UPDATE TO authenticated
USING (auth.uid() = id);

-- سياسات جدول أولياء الأمور (guardians)
DROP POLICY IF EXISTS "Allow guardians to read their own record" ON guardians;
CREATE POLICY "Allow guardians to read their own record" ON guardians
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow guardians to insert their own record" ON guardians;
CREATE POLICY "Allow guardians to insert their own record" ON guardians
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow guardians to update their own record" ON guardians;
CREATE POLICY "Allow guardians to update their own record" ON guardians
FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

-- سياسات جدول المعلمات (teachers)
DROP POLICY IF EXISTS "Allow teachers to read their own record" ON teachers;
CREATE POLICY "Allow teachers to read their own record" ON teachers
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow teachers to insert their own record" ON teachers;
CREATE POLICY "Allow teachers to insert their own record" ON teachers
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow teachers to update their own record" ON teachers;
CREATE POLICY "Allow teachers to update their own record" ON teachers
FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all teachers" ON teachers;
CREATE POLICY "Admins can view all teachers" ON teachers
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- سياسات جدول الأطفال (children)
DROP POLICY IF EXISTS "Guardians can insert their children" ON children;
CREATE POLICY "Guardians can insert their children" ON children
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM guardians WHERE id = children.guardian_id AND user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Guardians can view their children" ON children;
CREATE POLICY "Guardians can view their children" ON children
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM guardians WHERE id = children.guardian_id AND user_id = auth.uid()
  ) OR 
  EXISTS (
    SELECT 1 FROM teachers WHERE id = children.teacher_id AND user_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Guardians can update their children" ON children;
CREATE POLICY "Guardians can update their children" ON children
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM guardians WHERE id = children.guardian_id AND user_id = auth.uid()
  ) OR 
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- سياسات جدول الحضور (attendance)
DROP POLICY IF EXISTS "Teachers can manage attendance" ON attendance;
CREATE POLICY "Teachers can manage attendance" ON attendance
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM teachers t
    JOIN children c ON c.teacher_id = t.id
    WHERE c.id = attendance.child_id AND t.user_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

DROP POLICY IF EXISTS "Guardians can view their children attendance" ON attendance;
CREATE POLICY "Guardians can view their children attendance" ON attendance
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = attendance.child_id AND g.user_id = auth.uid()
  )
);

-- سياسات جدول التقارير (reports)
DROP POLICY IF EXISTS "Teachers can manage reports" ON reports;
CREATE POLICY "Teachers can manage reports" ON reports
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher')
  )
);

DROP POLICY IF EXISTS "Guardians can view their children reports" ON reports;
CREATE POLICY "Guardians can view their children reports" ON reports
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = reports.child_id AND g.user_id = auth.uid()
  )
);

-- سياسات سطل التخزين (Storage Bucket) لصور الأطفال
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'children');

DROP POLICY IF EXISTS "Allow public view of children photos" ON storage.objects;
CREATE POLICY "Allow public view of children photos" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'children');
