# Supabase Storage Setup Guide

This guide will help you configure Supabase Storage for image uploads in the student signup process.

## Required Information

To set up Supabase Storage, you need to provide the following:

1. **Supabase URL** - Your Supabase project URL
   - Format: `https://your-project-id.supabase.co`
   - Found in: Supabase Dashboard → Settings → API → Project URL

2. **Supabase Anon Key** - Your public anonymous key
   - Found in: Supabase Dashboard → Settings → API → Project API keys → `anon` `public`

3. **Bucket Name** - The storage bucket name (default: `student-kyc`)
   - You can create this in: Supabase Dashboard → Storage → Create Bucket

## Setup Steps

### 1. Create .env File

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` file and fill in your Supabase credentials:

   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key_here
   STUDENT_KYC_BUCKET=student-kyc
   ```

   **Important:** The `.env` file is already in `.gitignore` and will not be committed to version control.

### 2. Create Storage Bucket in Supabase

1. Go to your Supabase Dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **Create Bucket**
4. Name it: `student-kyc` (or update `STUDENT_KYC_BUCKET` in your `.env` file if you use a different name)
5. Set it as **Public bucket** (or configure RLS policies if private)
6. Click **Create**

### 3. Configure Storage Policies (Important!)

For public uploads, you need to set up Row Level Security (RLS) policies:

1. Go to **Storage** → **Policies** in Supabase Dashboard
2. Select your `student-kyc` bucket
3. Create policies for:
   - **INSERT**: Allow authenticated users to upload
   - **SELECT**: Allow public read access (if bucket is public)
   - **UPDATE**: Allow users to update their own files (optional)
   - **DELETE**: Allow users to delete their own files (optional)

Example Policy (for authenticated uploads):
```sql
-- Allow authenticated users to upload
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'student-kyc');

-- Allow public read access
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'student-kyc');
```

### 4. Test the Integration

After configuration:
1. Run the app: `flutter run`
2. Go through the signup process
3. Upload images - they should upload to Supabase Storage
4. Check Supabase Dashboard → Storage → `student-kyc` bucket to see uploaded files

## File Structure

Uploaded images are stored with the following structure:
```
student-kyc/
  ├── student-id/
  │   └── {userId}/
  │       └── {timestamp}.jpg
  └── selfie/
      └── {userId}/
          └── {timestamp}.jpg
```

## Security Notes

- The `anon` key is safe to use in client-side code, but ensure your storage policies are properly configured
- Consider using authenticated uploads for better security
- The user ID is currently generated from email (temporary solution)
- In production, use the authenticated user's ID from Supabase Auth

## Troubleshooting

**Error: "Failed to upload images"**
- Check that Supabase URL and Anon Key are correct
- Verify the bucket exists and is accessible
- Check storage policies are configured correctly

**Error: "Bucket not found"**
- Ensure the bucket name matches in `supabase_config.dart`
- Verify the bucket exists in Supabase Dashboard

**Images not appearing**
- Check if bucket is set to public or if RLS policies allow read access
- Verify the public URL is being generated correctly

