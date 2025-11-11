import React, { useState, useEffect } from 'react';
import { supabase } from '../../services/supabaseClient';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { Badge } from '../ui/badge';
import { Calendar, Loader2 } from 'lucide-react';

const UserAppointments = ({ user }) => {
  const [appointments, setAppointments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // Function to fetch appointments
  const fetchAppointments = async () => {
    if (!user) return;
    const { data, error } = await supabase
      .from('appointments')
      .select(`*, doctor:profiles(full_name)`) // Also fetches the doctor's name
      .eq('patient_id', user.id)
      .order('appointment_date', { ascending: false });
    
    if (error) {
      console.error("Error fetching appointments:", error);
    } else {
      setAppointments(data);
    }
    setIsLoading(false);
  };

  useEffect(() => {
    // Fetch initial data when the component loads
    fetchAppointments();

    // Set up a real-time subscription
    const channel = supabase
      .channel(`user-appointments-${user.id}`)
      .on(
        'postgres_changes',
        { 
          event: '*', 
          schema: 'public', 
          table: 'appointments',
          filter: `patient_id=eq.${user.id}` // Only listen for changes to this user's appointments
        },
        (payload) => {
          console.log('Change received!', payload);
          // When a change occurs, re-fetch all appointments to get the latest list
          fetchAppointments();
        }
      )
      .subscribe();

    // Cleanup the subscription when the component is removed
    return () => {
      supabase.removeChannel(channel);
    };
  }, [user]);

  const getStatusBadge = (status) => {
    if (status === 'confirmed') return <Badge className="bg-green-600 hover:bg-green-700">Confirmed</Badge>;
    if (status === 'pending') return <Badge variant="secondary">Pending</Badge>;
    if (status === 'cancelled') return <Badge variant="destructive">Cancelled</Badge>;
    return <Badge variant="outline">{status}</Badge>;
  };

  if (isLoading) {
    return <div className="flex items-center justify-center"><Loader2 className="h-8 w-8 animate-spin" /></div>;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center">
          <Calendar className="w-6 h-6 mr-3" /> My Appointments
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader><TableRow><TableHead>Doctor</TableHead><TableHead>Type</TableHead><TableHead>Date & Time</TableHead><TableHead>Status</TableHead></TableRow></TableHeader>
          <TableBody>
            {appointments.length > 0 ? appointments.map((appt) => (
              <TableRow key={appt.id}>
                <TableCell>{appt.doctor?.full_name || 'N/A'}</TableCell>
                <TableCell>{appt.type}</TableCell>
                <TableCell>{new Date(appt.appointment_date).toLocaleDateString()} at {appt.appointment_time}</TableCell>
                <TableCell>{getStatusBadge(appt.status)}</TableCell>
              </TableRow>
            )) : (
              <TableRow><TableCell colSpan={4} className="text-center">You have no appointments.</TableCell></TableRow>
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export default UserAppointments;