import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '../services/supabaseClient';



// --- UI & Icon Imports ---
import { Calendar, ClipboardList, Clock, Loader2, Stethoscope } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../components/ui/select';
import { Textarea } from '../components/ui/textarea';

const BookAppointmentPage = ({ user }) => {
  const [doctors, setDoctors] = useState([]);
  const [clinicianId, setClinicianId] = useState('');
  const [appointmentDate, setAppointmentDate] = useState('');
  const [appointmentTime, setAppointmentTime] = useState('');
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // --- FIX: This function will now only run if the 'user' object exists ---
    const fetchDoctors = async () => {
      // This guard clause prevents the fetch if the user prop hasn't been passed down yet.
      if (!user) return;

      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name, specialization')
        .eq('role', 'clinician');

      if (error) {
        toast.error('Error fetching doctors list.');
      } else {
        setDoctors(data);
      }
    };
    fetchDoctors();
  }, [user]); // --- FIX: Added 'user' as a dependency ---

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!clinicianId || !appointmentDate || !appointmentTime) {
      toast.error('Please fill all required fields.');
      return;
    }

    setIsSubmitting(true);

    const { error } = await supabase
      .from('appointments')
      .insert({
        patient_id: user.id,
        doctor_id: clinicianId, // Corrected column name
        appointment_date: appointmentDate,
        appointment_time: appointmentTime,
        type: reason,
        notes: '',    // <-- Add this line here
        status: 'pending'
      });

    if (error) {
      toast.error(`Failed to book appointment: ${error.message}`);
    } else {
      toast.success('Appointment request sent successfully!');
      navigate('/user/appointments');
    }
    
    setIsSubmitting(false);
  };

  const timeSlots = [
    '09:00:00', '09:30:00', '10:00:00', '10:30:00', '11:00:00',
    '14:00:00', '14:30:00', '15:00:00', '15:30:00', '16:00:00'
  ];

  // While waiting for the user prop, you can show a loader
  if (!user) {
    return (
        <div className="flex h-64 items-center justify-center">
            <Loader2 className="h-8 w-8 animate-spin" />
        </div>
    );
  }

  return (
    <div className="container mx-auto p-4 md:p-6">
      <Card className="w-full max-w-3xl mx-auto border-0 medical-shadow">
        <CardHeader className="text-center">
          <Stethoscope className="mx-auto h-12 w-12 text-[#0A3D62]" />
          <CardTitle className="mt-4 text-2xl font-bold text-[#0A3D62]">Book an Appointment</CardTitle>
          <CardDescription className="mt-2">
            Schedule a consultation with one of our specialists.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="doctor" className="flex items-center"><Stethoscope className="h-4 w-4 mr-2" />Select Doctor *</Label>
              <Select value={clinicianId} onValueChange={setClinicianId}>
                <SelectTrigger id="doctor">
                  <SelectValue placeholder="Choose a specialist..." />
                </SelectTrigger>
                <SelectContent>
                  {doctors.map((doctor) => (
                    <SelectItem key={doctor.id} value={doctor.id}>
                      <div className="flex flex-col">
                        <span className="font-medium">{doctor.full_name}</span>
                        <span className="text-xs text-gray-500">{doctor.specialization || 'Clinician'}</span>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="date" className="flex items-center"><Calendar className="h-4 w-4 mr-2" />Appointment Date *</Label>
                <Input id="date" type="date" value={appointmentDate} onChange={(e) => setAppointmentDate(e.target.value)} min={new Date().toISOString().split("T")[0]} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="time" className="flex items-center"><Clock className="h-4 w-4 mr-2" />Preferred Time *</Label>
                <Select id="time" value={appointmentTime} onValueChange={setAppointmentTime}>
                    <SelectTrigger>
                        <SelectValue placeholder="Select a time slot" />
                    </SelectTrigger>
                    <SelectContent>
                        {timeSlots.map(slot => (
                            <SelectItem key={slot} value={slot}>
                                {new Date(`1970-01-01T${slot}`).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })}
                            </SelectItem>
                        ))}
                    </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="reason" className="flex items-center"><ClipboardList className="h-4 w-4 mr-2" />Reason for Visit</Label>
              <Textarea id="reason" placeholder="Briefly describe your symptoms or reason for the visit..." value={reason} onChange={(e) => setReason(e.target.value)} />
            </div>

            <Button type="submit" className="w-full bg-[#0A3D62] hover:bg-[#1E5F8B]" disabled={isSubmitting}>
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {isSubmitting ? 'Submitting Request...' : 'Request Appointment'}
            </Button>
          </form>
        </CardContent>
        <CardFooter>
            <p className="text-xs text-gray-500 text-center w-full">Please note: This is a request. Your appointment will be confirmed by the clinic shortly.</p>
        </CardFooter>
      </Card>
    </div>
  );
};

export default BookAppointmentPage;

