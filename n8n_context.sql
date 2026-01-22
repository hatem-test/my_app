-- ============================================================
-- n8n Context SQL - تجهيز قاعدة البيانات للشات بوت
-- هذا الملف ينشئ Views (جداول افتراضية) لتسهيل القراءة على البوت
-- ============================================================

-- 1. View: ملف الطفل الكامل (n8n_child_profile)
-- يدمج بيانات الطفل مع بيانات الأم والمعلمة في مكان واحد
CREATE OR REPLACE VIEW view_n8n_child_profile AS
SELECT 
  c.id AS child_id,
  c.name AS child_name,
  c.gender,
  c.birth_date,
  -- حساب العمر بالسنوات
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birth_date)) AS age_years,
  c.class_name,
  c.allergies,
  -- بيانات الأم
  gm_user.name AS mother_name,
  gm_user.phone AS mother_phone,
  -- بيانات المعلمة
  t_user.name AS teacher_name
FROM children c
LEFT JOIN guardians g ON c.guardian_id = g.id
LEFT JOIN users gm_user ON g.user_id = gm_user.id
LEFT JOIN teachers t ON c.teacher_id = t.id
LEFT JOIN users t_user ON t.user_id = t_user.id;

-- 2. View: ملخص اليوم (n8n_daily_summary)
-- يدمج التقرير اليومي مع بيانات الحضور والانصراف
CREATE OR REPLACE VIEW view_n8n_daily_summary AS
SELECT 
  r.id AS report_id,
  r.child_id,
  r.report_date,
  -- تفاصيل التقرير
  r.health_status,
  r.activity,
  r.behavior,
  r.sleep,
  r.eating,
  r.additional_notes,
  -- تفاصيل الحضور (من جدول Attendance)
  a.check_in,
  a.check_out,
  a.status AS attendance_status
FROM reports r
LEFT JOIN attendance a ON r.child_id = a.child_id AND r.report_date = a.attendance_date;

-- 3. View: سجل الوجبات المفصل (n8n_meals_log)
-- يوضح ماذا أكل الطفل بالضبط (أسماء الوجبات ومكوناتها)
CREATE OR REPLACE VIEW view_n8n_meals_log AS
SELECT 
  ms.id AS selection_id,
  ms.child_id,
  m.meal_date,
  m.name AS meal_name,
  m.meal_type, -- breakfast, lunch, etc.
  m.items AS meal_components,
  m.time AS meal_time
FROM meal_selections ms
JOIN meals m ON ms.meal_id = m.id;

-- 4. View: السجل الصحي (n8n_health_log)
-- تبسيط الوصول للسجلات الصحية
CREATE OR REPLACE VIEW view_n8n_health_log AS
SELECT 
  h.id AS record_id,
  h.child_id,
  h.record_date,
  h.record_type, -- checkup, vaccination
  h.title,
  h.description,
  h.general_status,
  h.temperature,
  h.vaccinations
FROM health_records h;

-- منح صلاحيات القراءة (اختياري، يسهل الاختبار من الداشبورد)
-- البوت سيستخدم ال Service Role عادة والذي يملك صلاحيات كاملة، لكن هذا جيد للاختبار
GRANT SELECT ON view_n8n_child_profile TO authenticated, service_role;
GRANT SELECT ON view_n8n_daily_summary TO authenticated, service_role;
GRANT SELECT ON view_n8n_meals_log TO authenticated, service_role;
GRANT SELECT ON view_n8n_health_log TO authenticated, service_role;

-- ============================================================
-- تعليمات للاستخدام في n8n:
-- ============================================================
-- عند سؤال الأم عن "كيف كان يوم طفلي؟":
-- 1. ابحث في `view_n8n_child_profile` باستخدام اسم الام أو الـ User ID لمعرفة `child_id`
-- 2. استعلم من `view_n8n_daily_summary` باستخدام `child_id` و `CURRENT_DATE`
-- 
-- عند السؤال عن "ماذا أكل؟":
-- 1. استعلم من `view_n8n_meals_log`
-- ============================================================
