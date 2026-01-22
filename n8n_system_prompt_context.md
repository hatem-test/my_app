# System Prompt Context for n8n Chatbot

Add the following text to your AI Model's "System Prompt" or "Context" in n8n. This helps the AI understand how to query the database.

---
## Database Context (Supabase)

You have access to a Supabase PostgreSQL database with the following simplified Views designed for quick and accurate retrieval of child data.

### 1. `view_n8n_child_profile`
Contains basic info about the child and their parents/teachers.
- `child_id` (UUID)
- `child_name` (Text)
- `age_years` (Number)
- `mother_name` (Text)
- `teacher_name` (Text)

### 2. `view_n8n_daily_summary`
Contains the daily report and attendance for a specific date.
- `child_id` (UUID)
- `report_date` (Date)
- `check_in`, `check_out` (Times)
- `health_status`, `mood`, `sleep`, `eating` (Text descriptions from daily report)
- `additional_notes` (Text)

### 3. `view_n8n_meals_log`
Contains details of what the child ate.
- `child_id` (UUID)
- `meal_date` (Date)
- `meal_name` (e.g., "Breakfast")
- `meal_components` (List of items, e.g., ["Egg", "Milk"])

### 4. `view_n8n_health_log`
Contains medical records.
- `record_type` ("vaccination", "checkup")
- `general_status`, `temperature`

## Querying Tips
- Always fetch `child_id` first using the Mother's name or User ID.
- When asked "How was my child today?", query `view_n8n_daily_summary` for today's date.
- When asked "What did they eat?", query `view_n8n_meals_log`.
