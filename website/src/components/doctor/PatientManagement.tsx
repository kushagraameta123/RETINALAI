import React, { useState, useEffect, useMemo } from 'react';
import { supabase } from '../../services/supabaseClient';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { Badge } from '../ui/badge';
import { Input } from '../ui/input';
import { Button } from '../ui/button';
import { Users, Search, Eye } from 'lucide-react';

export default function PatientManagement() {
  const [patients, setPatients] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Function to fetch the initial list of patients
    const fetchPatients = async () => {
      setIsLoading(true);
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('role', 'patient') // Only fetch users with the 'patient' role
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching patients:', error.message);
      } else {
        setPatients(data);
      }
      setIsLoading(false);
    };

    fetchPatients();

    // Set up a real-time subscription to listen for new patients
    const channel = supabase
      .channel('public:profiles')
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'profiles', filter: 'role=eq.patient' },
        (payload) => {
          console.log('New patient detected!', payload.new);
          // Add the new patient to the top of the list
          setPatients(currentPatients => [payload.new, ...currentPatients]);
        }
      )
      .subscribe();

    // Cleanup function to remove the subscription
    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  // Filter patients based on the search term
  const filteredPatients = useMemo(() => {
    return patients.filter(patient =>
      patient.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      patient.email?.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }, [patients, searchTerm]);

  if (isLoading) {
    return <div>Loading patient data...</div>;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <div className="flex items-center">
            <Users className="w-6 h-6 mr-3 text-medical-blue" />
            Patient Management
          </div>
          <div className="relative w-1/3">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
            <Input 
              placeholder="Search by name or email..."
              className="pl-10"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </CardTitle>
        <CardDescription>
          A real-time list of all registered patients.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Full Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Joined On</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredPatients.map((patient) => (
              <TableRow key={patient.id}>
                <TableCell className="font-medium">{patient.full_name || 'N/A'}</TableCell>
                <TableCell>{patient.email}</TableCell>
                <TableCell>{new Date(patient.created_at).toLocaleDateString()}</TableCell>
                <TableCell><Badge variant="secondary">Active</Badge></TableCell>
                <TableCell className="text-right">
                  <Button variant="outline" size="sm">
                    <Eye className="w-4 h-4 mr-2" /> View Profile
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}