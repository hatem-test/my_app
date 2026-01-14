-- Enable RLS updates for users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Allow users to update their own profile
CREATE POLICY "Allow users to update own profile"
ON public.users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Allow guardians to update their own record
ALTER TABLE public.guardians ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow guardians to update own record"
ON public.guardians
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Allow teachers to update their own record
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow teachers to update own record"
ON public.teachers
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
