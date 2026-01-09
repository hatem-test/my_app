-- ============================================================
-- Schema SQL DDL لقاعدة بيانات تطبيق الحضانة (Supabase)
-- تم إنشاؤه بناءً على Dart Models
-- ============================================================

-- ============================================================
-- جدول المستخدمين (Users)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role VARCHAR(50) NOT NULL, -- 'mother', 'teacher', 'admin'
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- جدول أولياء الأمور (Guardians)
-- ============================================================
CREATE TABLE IF NOT EXISTS guardians (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  address TEXT,
  emergency_phone VARCHAR(20),
  relationship VARCHAR(100) DEFAULT 'أم',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول المعلمات (Teachers)
-- ============================================================
CREATE TABLE IF NOT EXISTS teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  specialization VARCHAR(255),
  hire_date DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول الأطفال (Children)
-- ============================================================
CREATE TABLE IF NOT EXISTS children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guardian_id UUID NOT NULL,
  teacher_id UUID,
  name VARCHAR(255) NOT NULL,
  birth_date DATE NOT NULL,
  gender VARCHAR(20) NOT NULL, -- 'boy', 'girl'
  image_url TEXT,
  allergies TEXT[], -- JSON array لتخزين الحساسيات
  class_name VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

-- ============================================================
-- جدول الحضور والانصراف (Attendance)
-- ============================================================
CREATE TABLE IF NOT EXISTS attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL,
  recorded_by UUID NOT NULL,
  check_in TIMESTAMP WITH TIME ZONE,
  check_out TIMESTAMP WITH TIME ZONE,
  status VARCHAR(50) NOT NULL, -- 'present', 'absent', 'late', 'leftEarly'
  attendance_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
  FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول السجلات الصحية (Health Records)
-- ============================================================
CREATE TABLE IF NOT EXISTS health_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL,
  general_status VARCHAR(255) NOT NULL,
  temperature VARCHAR(50),
  vaccinations TEXT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  record_type VARCHAR(50) NOT NULL, -- 'checkup', 'vaccination', 'note'
  record_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول الوجبات (Meals)
-- ============================================================
CREATE TABLE IF NOT EXISTS meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  time VARCHAR(10) NOT NULL, -- صيغة HH:MM
  items TEXT[] NOT NULL, -- JSON array لعناصر الوجبة
  meal_type VARCHAR(50) NOT NULL, -- 'breakfast', 'snack', 'lunch', 'dinner'
  meal_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- جدول اختيارات الوجبات (Meal Selections)
-- ============================================================
CREATE TABLE IF NOT EXISTS meal_selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL,
  meal_id UUID NOT NULL,
  selected_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
  FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE,
  FOREIGN KEY (selected_by) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول الملاحظات (Notes)
-- ============================================================
CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL,
  author_id UUID NOT NULL,
  content TEXT NOT NULL,
  is_sent_to_parent BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول الإشعارات (Notifications)
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(50) NOT NULL, -- 'report', 'message', 'system', 'attendance'
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- جدول التقارير اليومية (Reports)
-- ============================================================
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL,
  teacher_id UUID NOT NULL,
  health_status TEXT NOT NULL,
  activity TEXT NOT NULL,
  behavior TEXT NOT NULL,
  sleep TEXT NOT NULL,
  eating TEXT NOT NULL,
  additional_notes TEXT,
  report_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);

-- ============================================================
-- إنشاء الفهارس (Indexes)
-- ============================================================

-- Indexes للأداء العالية
CREATE INDEX IF NOT EXISTS idx_guardians_user_id ON guardians(user_id);
CREATE INDEX IF NOT EXISTS idx_teachers_user_id ON teachers(user_id);
CREATE INDEX IF NOT EXISTS idx_children_guardian_id ON children(guardian_id);
CREATE INDEX IF NOT EXISTS idx_children_teacher_id ON children(teacher_id);
CREATE INDEX IF NOT EXISTS idx_attendance_child_id ON attendance(child_id);
CREATE INDEX IF NOT EXISTS idx_attendance_recorded_by ON attendance(recorded_by);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(attendance_date);
CREATE INDEX IF NOT EXISTS idx_health_records_child_id ON health_records(child_id);
CREATE INDEX IF NOT EXISTS idx_health_records_date ON health_records(record_date);
CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(meal_date);
CREATE INDEX IF NOT EXISTS idx_meal_selections_child_id ON meal_selections(child_id);
CREATE INDEX IF NOT EXISTS idx_meal_selections_meal_id ON meal_selections(meal_id);
CREATE INDEX IF NOT EXISTS idx_meal_selections_selected_by ON meal_selections(selected_by);
CREATE INDEX IF NOT EXISTS idx_notes_child_id ON notes(child_id);
CREATE INDEX IF NOT EXISTS idx_notes_author_id ON notes(author_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_reports_child_id ON reports(child_id);
CREATE INDEX IF NOT EXISTS idx_reports_teacher_id ON reports(teacher_id);
CREATE INDEX IF NOT EXISTS idx_reports_date ON reports(report_date);

-- ============================================================
-- تفعيل Row Level Security (RLS)
-- ============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE guardians ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- ملاحظات مهمة:
-- ============================================================
-- 1. تم استخدام UUID للمفاتيح الأولية (متوافق مع Supabase)
-- 2. تم تحويل List<String> من Dart إلى TEXT[] array في PostgreSQL
-- 3. تم تحويل enum من Dart إلى VARCHAR للمرونة
-- 4. تم استخدام TIMESTAMP WITH TIME ZONE للتواريخ والأوقات
-- 5. تم إضافة Foreign Keys والعلاقات بين الجداول
-- 6. تم إضافة Indexes لتحسين الأداء
-- 7. RLS مفعل لكل الجداول (يتطلب سياسات إضافية حسب الحاجة)
-- ============================================================
