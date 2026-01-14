-- ============================================================
-- سياسات Row Level Security (RLS) لجدول الوجبات (meals)
-- ============================================================

-- 1) السماح للمعلمات والمدير بإنشاء وإدارة الوجبات
DROP POLICY IF EXISTS "Teachers and admins can manage meals" ON meals;
CREATE POLICY "Teachers and admins can manage meals" ON meals
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid() AND u.role IN ('teacher', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid() AND u.role IN ('teacher', 'admin')
  )
);

-- 2) السماح لأولياء الأمور بقراءة الوجبات المتاحة
DROP POLICY IF EXISTS "Guardians can view meals" ON meals;
CREATE POLICY "Guardians can view meals" ON meals
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid() AND u.role = 'mother'
  )
  OR
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid() AND u.role IN ('teacher', 'admin')
  )
);

-- ============================================================
-- سياسات Row Level Security (RLS) لجدول اختيارات الوجبات (meal_selections)
-- ============================================================

-- 1) السماح لأولياء الأمور بإنشاء اختيارات وجبات لأطفالهم
DROP POLICY IF EXISTS "Guardians can select meals for their children" ON meal_selections;
CREATE POLICY "Guardians can select meals for their children" ON meal_selections
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = meal_selections.child_id
      AND g.user_id = auth.uid()
  )
);

-- 2) السماح لأولياء الأمور بقراءة اختيارات وجبات أطفالهم
DROP POLICY IF EXISTS "Guardians can view their children meal selections" ON meal_selections;
CREATE POLICY "Guardians can view their children meal selections" ON meal_selections
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = meal_selections.child_id
      AND g.user_id = auth.uid()
  )
);

-- 3) السماح للمعلمات بقراءة اختيارات وجبات أطفالهم
DROP POLICY IF EXISTS "Teachers can view their children meal selections" ON meal_selections;
CREATE POLICY "Teachers can view their children meal selections" ON meal_selections
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM children c
    JOIN teachers t ON c.teacher_id = t.id
    WHERE c.id = meal_selections.child_id
      AND t.user_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid() AND u.role = 'admin'
  )
);

-- 4) السماح لأولياء الأمور بتحديث/حذف اختيارات وجبات أطفالهم
DROP POLICY IF EXISTS "Guardians can update their children meal selections" ON meal_selections;
CREATE POLICY "Guardians can update their children meal selections" ON meal_selections
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = meal_selections.child_id
      AND g.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = meal_selections.child_id
      AND g.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Guardians can delete their children meal selections" ON meal_selections;
CREATE POLICY "Guardians can delete their children meal selections" ON meal_selections
FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM children c
    JOIN guardians g ON c.guardian_id = g.id
    WHERE c.id = meal_selections.child_id
      AND g.user_id = auth.uid()
  )
);
