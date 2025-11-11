import { CalendarPlus, Loader2, Stethoscope } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '../../services/supabaseClient';
import { Button } from '../ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { Textarea } from '../ui/textarea';

const BookAppointment = ({ user }) => {
  const [doctors, setDoctors] = useState([]);
  const [selectedDoctor, setSelectedDoctor] = useState('');
  const [appointmentData, setAppointmentData] = useState({
    appointmentDate: '',
    appointmentTime: '',
    type: 'Routine Checkup',
    notes: ''
  });
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchDoctors = async () => {
      const { data, error } = await supabase.from('profiles').select('id, full_name').eq('role', 'clinician');
      if (error) toast.error("Could not fetch doctors.");
      else setDoctors(data);
    };
    fetchDoctors();
  }, []);

  // Replace your existing handleSubmit function with this one

// Replace your existing handleSubmit function with this one

const handleSubmit = async (e) => {
  e.preventDefault();
  if (!clinicianId || !appointmentDate || !appointmentTime) {
    toast.error('Please fill all required fields.');
    return;
  }

  setIsSubmitting(true);

  // --- START OF THE FIX ---
  // The date from your form state is in "YYYY-MM-DD" format from the input type="date",
  // but if it were in DD/MM/YYYY, this is how you would fix it.
  // Let's ensure it is in the correct format regardless.
  // The HTML <input type="date"> returns "YYYY-MM-DD" by default, so a split is not needed.
  // The issue might be how the date is being displayed vs what is being stored.
  // To be absolutely safe, let's just use the value directly, assuming the input is correct.
  // The previous fix attempt with split('/') was for a different date format.
  // The *real* problem is likely the RLS policy if the date input is standard.

  // Let's add a console log to be 100% certain what we are sending.
  const payload = {
      patient_id: user.id,
      clinician_id: clinicianId,
      appointment_date: appointmentDate, // Directly from the state
      appointment_time: appointmentTime,
      type: reason, // This is your 'reason' mapped to the 'type' column
      notes: '',    // <-- Add this line here
      status: 'pending'
  };

  console.log("SENDING TO SUPABASE:", payload); // <-- THIS WILL SHOW THE EXACT DATA

  // --- END OF THE FIX ---

  const { error } = await supabase
    .from('appointments')
    .insert(payload); // <-- Use the payload object

  if (error) {
    toast.error(`Failed to book appointment: ${error.message}`);
    console.error("FULL SUPABASE ERROR:", error); // Log the full error object
  } else {
    toast.success('Appointment request sent successfully!');
    navigate('/user/appointments');
  }
  
  setIsSubmitting(false);
};

  const appointmentTypes = ['Routine Checkup', 'Diabetic Retinopathy Screening', 'Follow-up Visit', 'Emergency'];

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <h2 className="text-2xl font-bold text-[#0A3D62] mb-2">Book New Appointment</h2>
      <Card>
        <CardHeader><CardTitle className="flex items-center"><CalendarPlus className="h-5 w-5 mr-2" />Appointment Details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <Label htmlFor="doctor">Select Doctor *</Label>
              <Select value={selectedDoctor} onValueChange={setSelectedDoctor}>
                <SelectTrigger><SelectValue placeholder="Choose a doctor..." /></SelectTrigger>
                <SelectContent>{doctors.map((doctor) => (<SelectItem key={doctor.id} value={doctor.id}><div className="flex items-center space-x-2"><Stethoscope className="h-4 w-4" /><p>{doctor.full_name}</p></div></SelectItem>))}</SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="date">Preferred Date *</Label>
                <Input id="date" type="date" value={appointmentData.appointmentDate} onChange={(e) => setAppointmentData({...appointmentData, appointmentDate: e.target.value})} min={new Date().toISOString().split('T')[0]} required />
              </div>
              <div>
                <Label htmlFor="time">Preferred Time *</Label>
                <Input id="time" type="time" value={appointmentData.appointmentTime} onChange={(e) => setAppointmentData({...appointmentData, appointmentTime: e.target.value})} required />
              </div>
            </div>
            <div>
              <Label htmlFor="type">Appointment Type *</Label>
              <Select value={appointmentData.type} onValueChange={(value) => setAppointmentData({...appointmentData, type: value})}>
                <SelectTrigger><SelectValue placeholder="Select appointment type" /></SelectTrigger>
                <SelectContent>{appointmentTypes.map((type) => (<SelectItem key={type} value={type}>{type}</SelectItem>))}</SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="notes">Additional Notes or Symptoms</Label>
              <Textarea id="notes" placeholder="Describe any symptoms..." value={appointmentData.notes} onChange={(e) => setAppointmentData({...appointmentData, notes: e.target.value})} rows={3} />
            </div>
            <Button type="submit" className="w-full" disabled={isLoading}>{isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}{isLoading ? 'Submitting...' : 'Submit Appointment Request'}</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

export default BookAppointment;