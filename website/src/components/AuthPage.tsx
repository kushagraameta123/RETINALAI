import { Eye, Shield, Stethoscope, UserCircle, ShieldCheck } from 'lucide-react'; // Added ShieldCheck icon
import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import Footer from './Footer';
import { Button } from './ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Checkbox } from './ui/checkbox';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { supabase } from '../services/supabaseClient'; // Adjust path if necessary
import { toast } from 'sonner'; // Using toast for notifications

export default function AuthPage() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [loginForm, setLoginForm] = useState({
    email: '',
    password: ''
  });
  
  // --- NEW: Added state to manage the selected role for the login form ---
  const [loginRole, setLoginRole] = useState('patient'); 

  const [signupForm, setSignupForm] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    role: '', 
    agreedToTerms: false
  });

  // --- MODIFIED: The handleLogin function is now secure and verifies the role ---
  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);

    // Step 1: Authenticate the user with email and password
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: loginForm.email,
      password: loginForm.password,
    });

    if (authError || !authData.user) {
      toast.error(authError?.message || 'Invalid login credentials.');
      setIsLoading(false);
      return;
    }

    // Step 2: Fetch the user's actual role from the secure 'profiles' table
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', authData.user.id)
      .single();

    if (profileError || !profile) {
      toast.error('Could not verify user profile. Please contact support.');
      await supabase.auth.signOut(); // Security: Sign out if profile is missing
      setIsLoading(false);
      return;
    }

    // Step 3: Verify if the selected role matches the one in the database
    if (profile.role === loginRole) {
      toast.success('Sign in successful!');
      // Redirect based on the *verified* role
      switch (loginRole) {
        case 'patient':
          navigate('/user/dashboard');
          break;
        case 'clinician':
          navigate('/clinician/dashboard');
          break;
        case 'admin':
          navigate('/admin/dashboard');
          break;
        default:
          navigate('/');
      }
    } else {
      toast.error(`Invalid role. This account is not registered as a '${loginRole}'.`);
      await supabase.auth.signOut(); // Security: Sign out immediately on role mismatch
    }

    setIsLoading(false);
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    if (signupForm.password !== signupForm.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }
    if (!signupForm.agreedToTerms) {
      toast.error('Please agree to the terms and conditions');
      return;
    }

    setIsLoading(true);

    const { data, error } = await supabase.auth.signUp({
      email: signupForm.email,
      password: signupForm.password,
      options: {
        data: {
          full_name: signupForm.name, // Ensure this matches your profiles table column
          role: signupForm.role,
        }
      }
    });

    setIsLoading(false);

    if (error) {
      toast.error(`Error: ${error.message}`);
      return;
    }

    if (data.user) {
      toast.success('Sign-up successful! Please check your email for a verification link.');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-white flex flex-col">
      <div className="flex-1 flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <Link to="/" className="inline-flex items-center space-x-2 text-2xl font-bold text-gray-900">
              <Eye className="h-8 w-8 text-blue-600" />
              <span>Retinal-AI</span>
            </Link>
            <p className="text-gray-600 mt-2">Sign in to your account</p>
          </div>

          <Tabs defaultValue="login" className="w-full">
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="login">Login</TabsTrigger>
              <TabsTrigger value="signup">Sign Up</TabsTrigger>
            </TabsList>

            <TabsContent value="login">
              <Card>
                <CardHeader>
                  <CardTitle>Welcome Back</CardTitle>
                  <CardDescription>
                    Enter your credentials to access your account
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <form onSubmit={handleLogin} className="space-y-4">

                    {/* --- NEW: Role Selector for Login Form --- */}
                    <div className="space-y-2">
                      <Label htmlFor="login-role" className="flex items-center">
                        <ShieldCheck className="h-4 w-4 mr-2" />
                        Sign in as
                      </Label>
                      <Select value={loginRole} onValueChange={setLoginRole}>
                        <SelectTrigger id="login-role">
                          <SelectValue placeholder="Select your role" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="patient">Patient</SelectItem>
                          <SelectItem value="clinician">Clinician</SelectItem>
                          <SelectItem value="admin">Admin</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="email">Email</Label>
                      <Input
                        id="email"
                        type="email"
                        placeholder="doctor@example.com"
                        value={loginForm.email}
                        onChange={(e) => setLoginForm({ ...loginForm, email: e.target.value })}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="password">Password</Label>
                      <Input
                        id="password"
                        type="password"
                        value={loginForm.password}
                        onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                        required
                      />
                    </div>
                    <div className="text-right">
                      <Link to="/forgot-password" className="text-sm text-blue-600 hover:underline">
                        Forgot password?
                      </Link>
                    </div>
                    <Button type="submit" className="w-full" disabled={isLoading}>
                      {isLoading ? 'Signing In...' : 'Sign In'}
                    </Button>
                  </form>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="signup">
              {/* --- Your existing Signup form remains unchanged --- */}
              <Card>
                <CardHeader>
                  <CardTitle>Create Account</CardTitle>
                  <CardDescription>
                    Join our platform to start analyzing retinal images
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <form onSubmit={handleSignup} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="name">Full Name</Label>
                      <Input
                        id="name"
                        type="text"
                        placeholder="Dr. John Smith"
                        value={signupForm.name}
                        onChange={(e) => setSignupForm({ ...signupForm, name: e.target.value })}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="signup-email">Email</Label>
                      <Input
                        id="signup-email"
                        type="email"
                        placeholder="john.smith@hospital.com"
                        value={signupForm.email}
                        onChange={(e) => setSignupForm({ ...signupForm, email: e.target.value })}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="role">Role</Label>
                      <Select
                        value={signupForm.role}
                        onValueChange={(value) => setSignupForm({ ...signupForm, role: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select your role" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="patient">
                            <div className="flex items-center space-x-2">
                              <UserCircle className="h-4 w-4" />
                              <span>Patient/User</span>
                            </div>
                          </SelectItem>
                          <SelectItem value="clinician">
                            <div className="flex items-center space-x-2">
                              <Stethoscope className="h-4 w-4" />
                              <span>Healthcare Provider</span>
                            </div>
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="signup-password">Password</Label>
                      <Input
                        id="signup-password"
                        type="password"
                        value={signupForm.password}
                        onChange={(e) => setSignupForm({ ...signupForm, password: e.target.value })}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="confirm-password">Confirm Password</Label>
                      <Input
                        id="confirm-password"
                        type="password"
                        value={signupForm.confirmPassword}
                        onChange={(e) => setSignupForm({ ...signupForm, confirmPassword: e.target.value })}
                        required
                      />
                    </div>
                    <div className="flex items-center space-x-2">
                      <Checkbox
                        id="terms"
                        checked={signupForm.agreedToTerms}
                        onCheckedChange={(checked) => setSignupForm({ ...signupForm, agreedToTerms: !!checked })}
                      />
                      <Label htmlFor="terms" className="text-sm">
                        I agree to the{' '}
                        <Link to="/terms" className="text-blue-600 hover:underline">
                          Terms of Service
                        </Link>{' '}
                        and{' '}
                        <Link to="/privacy" className="text-blue-600 hover:underline">
                          Privacy Policy
                        </Link>
                      </Label>
                    </div>
                    <Button type="submit" className="w-full" disabled={isLoading || !signupForm.role}>
                      {isLoading ? 'Creating Account...' : 'Create Account'}
                    </Button>
                  </form>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
          <div className="text-center mt-6">
            <Link to="/" className="text-sm text-gray-600 hover:text-blue-600">
              ← Back to Home
            </Link>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}