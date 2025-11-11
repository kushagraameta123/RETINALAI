import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ouzglqvtiovjramkjkez.supabase.co'; 
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91emdscXZ0aW92anJhbWtqa2V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2OTU1MzksImV4cCI6MjA3MzI3MTUzOX0.mG_pK1jDOrdl0VhwTIBFjjqfxdyJ2eZv1k4mUcmIjZs';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
