import React, { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { supabase } from '../services/supabaseClient';
import { User } from '@supabase/supabase-js';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles: string[];
}

const ProtectedRoute = ({ children, allowedRoles }: ProtectedRouteProps) => {
  const [user, setUser] = useState<User | null>(null);
  const [profileStatus, setProfileStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const checkUser = async () => {
      // First, get the authentication user
      const { data: { session } } = await supabase.auth.getSession();
      const authUser = session?.user ?? null;
      setUser(authUser);

      if (authUser) {
        // If the user is logged in, fetch their profile from the database
        const { data: profile, error } = await supabase
          .from('profiles')
          .select('status')
          .eq('id', authUser.id)
          .single();
        
        if (error) {
          console.error("Error fetching user profile:", error);
        } else {
          setProfileStatus(profile?.status);
        }
      }
      setIsLoading(false);
    };

    checkUser();
  }, []);

  if (isLoading) {
    return <div>Loading...</div>; // Or a loading spinner
  }

  // If there is no user, redirect to the authentication page
  if (!user) {
    return <Navigate to="/auth" replace />;
  }
  
  // --- THIS IS THE NEW SECURITY CHECK ---
  // If the user's profile status is pending, redirect them to a special page
  if (profileStatus === 'pending_verification') {
    return <Navigate to="/pending-verification" replace />;
  }
  
  // If the user's role is not in the list of allowed roles, deny access
  const userRole = user.user_metadata.role;
  if (!allowedRoles.includes(userRole)) {
    // Redirect to a safe default page, like the user dashboard or home
    return <Navigate to="/" replace />;
  }

  // If all checks pass, show the page content
  return <>{children}</>;
};

export default ProtectedRoute;