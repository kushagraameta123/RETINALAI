import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { toast } from 'sonner';

// Reverting to the relative path for the Supabase client
import { supabase } from '../services/supabaseClient';

// UI & Icon Imports (Assuming standard '@/' alias)
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Calendar, Loader2, AlertTriangle } from 'lucide-react';

const UserAppointments = ({ user }) => {
  const [appointments, setAppointments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!user) {
        setIsLoading(false);
        return;
    }

    const fetchAppointmentsWithClinicians = async () => {
      setIsLoading(true);
      setError(null);
      try {
        // Step 1: Fetch the user's appointments
        const { data: appointmentsData, error: appointmentsError } = await supabase
          .from('appointments')
          .select('*') // Select all columns for now
          .eq('patient_id', user.id)
          .order('appointment_date', { ascending: false });

        if (appointmentsError) throw appointmentsError;

        if (!appointmentsData || appointmentsData.length === 0) {
            setAppointments([]);
            setIsLoading(false);
            return;
        }

        // Step 2: Get a unique list of all clinician IDs from the appointments
        const clinicianIds = [...new Set(appointmentsData.map(appt => appt.clinician_id).filter(id => id))];
        
        let cliniciansMap = new Map();

        // Step 3: If there are any clinician IDs, fetch their profiles
        if (clinicianIds.length > 0) {
            const { data: cliniciansData, error: cliniciansError } = await supabase
                .from('profiles')
                const clinicianIds = [...new Set(appointmentsData.map(appt => appt.doctor_id).filter(id => id))];

            if (cliniciansError) throw cliniciansError;
            
            // Create a simple map for easy lookup (id -> full_name)
            cliniciansData.forEach(c => cliniciansMap.set(c.id, c.full_name));
        }

        // Step 4: Combine the appointment data with the clinician's name
        const combinedData = appointmentsData.map(appt => ({
            ...appt,
            clinician_name: cliniciansMap.get(appt.clinician_id) || 'N/A'
        }));

        setAppointments(combinedData);

      } catch (err) {
        toast.error("Could not load your appointments.");
        setError(err.message);
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchAppointmentsWithClinicians();

  }, [user]);

  const getStatusBadge = (status: string) => {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return <Badge className="bg-green-100 text-green-800">Confirmed</Badge>;
      case 'pending':
        return <Badge className="bg-yellow-100 text-yellow-800">Pending</Badge>;
      case 'cancelled':
        return <Badge className="bg-red-100 text-red-800">Cancelled</Badge>;
      default:
        return <Badge variant="outline">{status}</Badge>;
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  if (error) {
    return (
      <Card className="text-center p-8">
        <AlertTriangle className="mx-auto h-12 w-12 text-red-400" />
        <h3 className="mt-4 text-lg font-medium text-red-800">Failed to Load Appointments</h3>
        <p className="mt-1 text-sm text-red-600">{error}</p>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <div className="flex items-center">
            <Calendar className="w-6 h-6 mr-3" />
            My Appointments
          </div>
          <Link to="/user/book-appointment">
            <Button>Book New Appointment</Button>
          </Link>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Clinician</TableHead>
              <TableHead>Date & Time</TableHead>
              <TableHead>Reason</TableHead>
              <TableHead className="text-right">Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {appointments.length > 0 ? (
              appointments.map((appt) => (
                <TableRow key={appt.id}>
                  <TableCell>{appt.clinician_name}</TableCell>
                  <TableCell>
                    {new Date(appt.appointment_date).toLocaleDateString()} at {new Date(`1970-01-01T${appt.appointment_time}`).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </TableCell>
                  <TableCell>{appt.reason_for_visit}</TableCell>
                  <TableCell className="text-right">{getStatusBadge(appt.status)}</TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={4} className="text-center h-24">
                  You have no appointments scheduled.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export default UserAppointments;

