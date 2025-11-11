-- Rename 'user_type' back to 'role' to match the Flutter code in AuthProvider.
ALTER TABLE public.profiles RENAME COLUMN user_type TO role;