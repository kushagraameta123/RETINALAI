import React, { useState, useEffect } from 'react';
import { supabase } from '../../services/supabaseClient';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { Badge } from '../ui/badge';
import { Input } from '../ui/input';
import { Button } from '../ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '../ui/dialog';
import { Label } from '../ui/label';
import { toast } from 'sonner';
import { Users, UserCheck, Clock } from 'lucide-react';

export default function UserManagement() {
  const [profiles, setProfiles] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedProfile, setSelectedProfile] = useState(null);
  const [licenseNumber, setLicenseNumber] = useState('');

  const fetchProfiles = async () => {
    const { data, error } = await supabase.from('profiles').select('*').order('created_at', { ascending: false });
    if (error) console.error('Error fetching profiles:', error.message);
    else setProfiles(data);
    setIsLoading(false);
  };

  useEffect(() => {
    fetchProfiles();
    const channel = supabase.channel('public:profiles').on('postgres_changes', { event: '*', schema: 'public', table: 'profiles' }, payload => {
        fetchProfiles(); // Re-fetch all data on any change
      }).subscribe();
    return () => { supabase.removeChannel(channel); };
  }, []);

  const handleApprove = async () => {
    if (!selectedProfile || !licenseNumber.trim()) {
      toast.error("Please enter a license number.");
      return;
    }
    const { error } = await supabase
      .from('profiles')
      .update({ status: 'active', license_number: licenseNumber })
      .eq('id', selectedProfile.id);

    if (error) {
      toast.error(`Failed to approve: ${error.message}`);
    } else {
      toast.success(`${selectedProfile.full_name} has been approved and is now active.`);
      setSelectedProfile(null);
      setLicenseNumber('');
    }
  };

  const getStatusBadge = (status) => {
    if (status === 'active') return <Badge className="bg-green-600">Active</Badge>;
    if (status === 'pending_verification') return <Badge variant="secondary" className="bg-yellow-500">Pending Verification</Badge>;
    return <Badge variant="outline">{status}</Badge>;
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center"><Users className="w-6 h-6 mr-3" /> User Management</CardTitle>
        <CardDescription>Approve new clinicians and manage all users in the system.</CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader><TableRow><TableHead>Full Name</TableHead><TableHead>Email</TableHead><TableHead>Role</TableHead><TableHead>Status</TableHead><TableHead>Actions</TableHead></TableRow></TableHeader>
          <TableBody>
            {profiles.map((profile) => (
              <TableRow key={profile.id}>
                <TableCell>{profile.full_name || 'N/A'}</TableCell>
                <TableCell>{profile.email}</TableCell>
                <TableCell><Badge variant="outline">{profile.role}</Badge></TableCell>
                <TableCell>{getStatusBadge(profile.status)}</TableCell>
                <TableCell>
                  {profile.role === 'clinician' && profile.status === 'pending_verification' && (
                    <Dialog onOpenChange={(open) => !open && setSelectedProfile(null)}>
                      <DialogTrigger asChild>
                        <Button size="sm" onClick={() => setSelectedProfile(profile)}>
                          <UserCheck className="w-4 h-4 mr-2" /> Approve
                        </Button>
                      </DialogTrigger>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>Approve Clinician: {selectedProfile?.full_name}</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                          <Label htmlFor="license">Enter Medical License Number</Label>
                          <Input id="license" value={licenseNumber} onChange={(e) => setLicenseNumber(e.target.value)} />
                        </div>
                        <Button onClick={handleApprove}>Confirm Approval</Button>
                      </DialogContent>
                    </Dialog>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}