-- Create a bucket 'images' if it doesn't exist
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow authenticated users to upload child images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update child images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to delete child images" ON storage.objects;

-- Policy: Allow authenticated users to upload to 'images' bucket (specifically under 'child/')
CREATE POLICY "Allow authenticated users to upload child images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images' AND (storage.foldername(name))[1] = 'child');

-- Policy: Allow authenticated users to update their uploaded images
CREATE POLICY "Allow authenticated users to update child images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'images' AND (storage.foldername(name))[1] = 'child')
WITH CHECK (bucket_id = 'images' AND (storage.foldername(name))[1] = 'child');

-- Policy: Allow public access to read images
CREATE POLICY "Allow public read access to images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'images');

-- Policy: Allow authenticated users to delete child images
CREATE POLICY "Allow authenticated users to delete child images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'images' AND (storage.foldername(name))[1] = 'child');
