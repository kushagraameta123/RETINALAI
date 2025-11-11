import React, { useEffect, useState } from 'react';
import { Navigate, Route, BrowserRouter as Router, Routes } from 'react-router-dom';
import { User } from '@supabase/supabase-js';
import { supabase } from './services/supabaseClient';

// --- Your Component Imports ---
import AdminDashboard from './components/AdminDashboard';
import ArticlePage from './components/ArticlePage';
import AuthPage from './components/AuthPage';
import DoctorDashboard from './components/DoctorDashboard';
import EducationHub from './components/EducationHub';
import ForgotPasswordPage from './components/ForgotPasswordPage';
import LandingPage from './components/LandingPage';
import EnhancedVisionChatBot from './components/EnhancedVisionChatBot';
import ProtectedRoute from './components/ProtectedRoute';
import UpdatePasswordPage from './components/UpdatePasswordPage';
import UserDashboard from './components/UserDashboard';
import PendingVerificationPage from './components/PendingVerificationPage';

export default function App() {
  const [user, setUser] = useState<User | null>(null);
  const [userRole, setUserRole] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check for an active session on initial load
    const checkActiveSession = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      
      if (session?.user) {
        setUser(session.user);
        setUserRole(session.user.user_metadata.role);
      }
      setIsLoading(false);
    };

    checkActiveSession();

    // Set up a real-time listener for auth changes (login/logout)
    const { data: authListener } = supabase.auth.onAuthStateChange((event, session) => {
      const currentUser = session?.user ?? null;
      setUser(currentUser);
      setUserRole(currentUser?.user_metadata.role ?? null);
    });

    // Clean up the listener when the component unmounts
    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        {/* You can keep your styled loading spinner here */}
        <p>Loading...</p> 
      </div>
    );
  }

  return (
    <Router>
      <div className="min-h-screen bg-background">
        <Routes>
          <Route path="/" element={user ? <Navigate to="/dashboard" /> : <LandingPage />} />
          <Route path="/auth" element={user ? <Navigate to="/dashboard" /> : <AuthPage />} />
          <Route path="/pending-verification" element={<PendingVerificationPage />} />
          
          {/* Public Pages */}
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/update-password" element={<UpdatePasswordPage />} />
          <Route path="/education" element={<EducationHub />} />
          <Route path="/education/:articleId" element={<ArticlePage />} />
          <Route path="/chatbot" element={<EnhancedVisionChatBot />} />
          
          {/* Protected Routes using Wildcards */}
          <Route 
            path="/doctor/*" 
            element={<ProtectedRoute allowedRoles={['clinician']}><DoctorDashboard /></ProtectedRoute>} 
          />
          <Route 
            path="/user/*" 
            element={<ProtectedRoute allowedRoles={['patient']}><UserDashboard /></ProtectedRoute>} 
          />
          <Route 
            path="/admin/*" 
            element={<ProtectedRoute allowedRoles={['admin']}><AdminDashboard /></ProtectedRoute>} 
          />

          {/* Dashboard redirect logic */}
          <Route 
            path="/dashboard" 
            element={
              user ? (
                userRole === 'clinician' ? <Navigate to="/doctor" replace /> :
                userRole === 'admin' ? <Navigate to="/admin" replace /> :
                <Navigate to="/user" replace />
              ) : (
                <Navigate to="/auth" replace />
              )
            } 
          />
          
          {/* Catch-all route */}
          <Route path="*" element={user ? <Navigate to="/dashboard" replace /> : <Navigate to="/" replace />} />
        </Routes>
      </div>
    </Router>
  );
}