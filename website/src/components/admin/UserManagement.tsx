import { UserCheck, Users } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { toast } from 'sonner';
import { supabase } from '../../services/supabaseClient';
import { Badge } from '../ui/badge';
import { Button } from '../ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../ui/dialog';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';

export default function UserManagement() {
  const [profiles, setProfiles] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedProfile, setSelectedProfile] = useState(null);
  const [licenseNumber, setLicenseNumber] = useState('');
  const [isApproving, setIsApproving] = useState(false);

  const fetchProfiles = async () => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (error) {
        console.error('Error fetching profiles:', error.message);
        toast.error('Failed to load users');
      } else {
        setProfiles(data || []);
      }
    } catch (error) {
      console.error('Error fetching profiles:', error);
      toast.error('Failed to load users');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchProfiles();
    
    // Real-time subscription
    const channel = supabase
      .channel('public:profiles')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'profiles' },
        () => {
          fetchProfiles(); // Re-fetch all data on any change
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const handleConfirmApprove = async () => {
    if (!licenseNumber.trim()) {
      toast.error('Please enter a medical license number');
      return;
    }

    if (!selectedProfile) {
      toast.error('No user selected for approval');
      return;
    }

    try {
      setIsApproving(true);
      
      // Actually update the user in database
      const { data, error } = await supabase
        .from('profiles')
        .update({ 
          status: 'active',
          license_number: licenseNumber.trim()
        })
        .eq('id', selectedProfile.id);

      if (error) throw error;

      // Refresh the users list
      await fetchProfiles();
      
      // Reset state
      setLicenseNumber('');
      setSelectedProfile(null);
      
      toast.success('Clinician approved successfully!');
    } catch (error) {
      console.error('Error approving clinician:', error);
      toast.error('Error approving clinician: ' + error.message);
    } finally {
      setIsApproving(false);
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'active':
        return <Badge className="bg-green-600 text-white">Active</Badge>;
      case 'pending_verification':
        return <Badge className="bg-yellow-500 text-white">Pending Verification</Badge>;
      case 'pending':
        return <Badge className="bg-orange-500 text-white">Pending</Badge>;
      default:
        return <Badge variant="outline">{status || 'Unknown'}</Badge>;
    }
  };

  const handleDialogClose = () => {
    setSelectedProfile(null);
    setLicenseNumber('');
  };

  if (isLoading) {
    return (
      <Card>
        <CardContent className="flex justify-center items-center py-8">
          <div>Loading users...</div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center">
          <Users className="w-6 h-6 mr-3" /> 
          User Management
        </CardTitle>
        <CardDescription>
          Approve new clinicians and manage all users in the system.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Full Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {profiles.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-4">
                  No users found
                </TableCell>
              </TableRow>
            ) : (
              profiles.map((profile) => (
                <TableRow key={profile.id}>
                  <TableCell className="font-medium">
                    {profile.full_name || 'N/A'}
                  </TableCell>
                  <TableCell>{profile.email}</TableCell>
                  <TableCell>
                    <Badge variant="outline">
                      {profile.role || 'N/A'}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    {getStatusBadge(profile.status)}
                  </TableCell>
                  <TableCell>
                    {profile.role === 'clinician' && 
                     (profile.status === 'pending' || profile.status === 'pending_verification') && (
                      <Dialog onOpenChange={(open) => !open && handleDialogClose()}>
                        <DialogTrigger asChild>
                          <Button 
                            size="sm" 
                            onClick={() => setSelectedProfile(profile)}
                            variant="default"
                          >
                            <UserCheck className="w-4 h-4 mr-2" /> 
                            Approve
                          </Button>
                        </DialogTrigger>
                        <DialogContent>
                          <DialogHeader>
                            <DialogTitle>
                              Approve Clinician: {selectedProfile?.full_name || 'Unknown'}
                            </DialogTitle>
                          </DialogHeader>
                          <div className="py-4 space-y-4">
                            <div>
                              <Label htmlFor="license">
                                Enter Medical License Number *
                              </Label>
                              <Input 
                                id="license" 
                                value={licenseNumber} 
                                onChange={(e) => setLicenseNumber(e.target.value)}
                                placeholder="Enter license number"
                                className="mt-2"
                              />
                            </div>
                            <div className="flex justify-end space-x-2">
                              <Button 
                                variant="outline" 
                                onClick={handleDialogClose}
                              >
                                Cancel
                              </Button>
                              <Button 
                                onClick={handleConfirmApprove}
                                disabled={!licenseNumber.trim() || isApproving}
                              >
                                {isApproving ? 'Approving...' : 'Confirm Approval'}
                              </Button>
                            </div>
                          </div>
                        </DialogContent>
                      </Dialog>
                    )}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}