import React from 'react';
import { supabase } from '../services/supabaseClient';
import { useNavigate } from 'react-router-dom';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Clock, LogOut } from 'lucide-react';

export default function PendingVerificationPage() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/auth');
  };

  return (
    <div className="flex justify-center items-center min-h-screen bg-gray-50">
      <Card className="w-full max-w-lg text-center">
        <CardHeader>
          <div className="mx-auto bg-yellow-100 p-3 rounded-full w-fit">
            <Clock className="h-8 w-8 text-yellow-600" />
          </div>
          <CardTitle className="mt-4">Account Pending Approval</CardTitle>
          <CardDescription>
            Thank you for registering as a clinician. Your account is currently under review by an administrator.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground mb-6">
            You will receive an email notification once your account has been approved. If you have any questions, please contact support.
          </p>
          <Button onClick={handleLogout} variant="outline">
            <LogOut className="w-4 h-4 mr-2" />
            Logout
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}