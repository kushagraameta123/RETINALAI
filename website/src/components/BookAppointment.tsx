import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '../services/supabaseClient';

// --- UI & Icon Imports ---
import { Calendar, ClipboardList, Clock, Loader2, Stethoscope, CheckCircle, UserX } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../components/ui/select';
import { Textarea } from '../components/ui/textarea';
import { Badge } from '../components/ui/badge';

const BookAppointmentPage = ({ user }) => {
  // ✅ HARCODED DOCTORS LIST
  const hardcodedDoctors = [
    { id: '3792d6d8-3072-48cd-ab84-b24c16cd3826', full_name: 'testdoc', specialization: 'Ophthalmologist' },
    { id: '6e80ab36-640e-4343-aaf5-d6f1a8b61b33', full_name: 'Test doctor', specialization: 'Ophthalmologist' },
    { id: '83581121-a946-4a97-89b9-a6390f999aef', full_name: 'tarun', specialization: 'Ophthalmologist' },
    { id: '502db88e-7224-4899-95a2-da24d84d51bd', full_name: 'DR. NIGGA', specialization: 'Ophthalmologist' },
    { id: '2989ca37-c2b6-4c71-a975-987ee61a5c54', full_name: 'fe', specialization: 'Ophthalmologist' },
    { id: '80d2e9f0-6776-4251-97d5-f35d8b29cf32', full_name: 'Keshav Ameta', specialization: 'Ophthalmologist' },
    { id: '30874ed9-ae83-4232-b684-07d48b5230a0', full_name: 'jjj', specialization: 'Ophthalmologist' },
    { id: '2bc5a6fc-cc34-4c1d-8645-e19b63f8b337', full_name: 'Tarun', specialization: 'Ophthalmologist' },
    { id: 'b4ad9dec-b263-4b61-b2a8-fecd6b123014', full_name: 'tt', specialization: 'Ophthalmologist' },
    { id: '9e2b716b-af11-4112-8df9-17a7c18584a0', full_name: 'testuser', specialization: 'Ophthalmologist' },
    { id: 'ff6057d5-1dbf-4137-a794-4624389333d7', full_name: 'abhishek', specialization: 'Ophthalmologist' },
    { id: '4456a66b-3121-45bc-856f-33c8d6f13d5b', full_name: 'TestDOC1', specialization: 'Ophthalmologist' },
    { id: 'a252358e-aae3-4d34-8c37-638b1e8b9c29', full_name: 'Kushagra technical', specialization: 'Ophthalmologist' },
    { id: '8de7451b-2dba-4d7a-bb44-abb6ffd468d0', full_name: 'fwfw', specialization: 'Ophthalmologist' },
    { id: 'b56ed314-84ec-4faa-a224-d45f6f5bfebe', full_name: 'kush21', specialization: 'Ophthalmologist' }
  ];

  const [doctors, setDoctors] = useState([]);
  const [clinicianId, setClinicianId] = useState('');
  const [appointmentDate, setAppointmentDate] = useState('');
  const [appointmentTime, setAppointmentTime] = useState('');
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // ✅ Just use the hardcoded doctors directly
    const doctorsWithAvailability = hardcodedDoctors.map(doctor => ({
      ...doctor,
      isAvailable: true, // Assume all are available for now
      availabilityStatus: 'available',
      todayAppointmentCount: Math.floor(Math.random() * 5) // Random number for demo
    }));

    setDoctors(doctorsWithAvailability);
  }, []);

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
        doctor_id: clinicianId,
        appointment_date: appointmentDate,
        appointment_time: appointmentTime,
        type: reason,
        notes: '',
        status: 'pending'
      });

    if (error) {
      console.error('Appointment submission error:', error);
      toast.error(`Failed to book appointment: ${error.message}`);
    } else {
      toast.success('Appointment request sent successfully!');
      navigate('/user/appointments');
    }
    
    setIsSubmitting(false);
  };

  const getAvailabilityBadge = (doctor) => {
    if (!appointmentDate || !appointmentTime) {
      return (
        <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200 text-xs">
          <Clock className="h-3 w-3 mr-1" />
          Select time
        </Badge>
      );
    }

    return (
      <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200 text-xs">
        <CheckCircle className="h-3 w-3 mr-1" />
        Available
      </Badge>
    );
  };

  const timeSlots = [
    '09:00:00', '09:30:00', '10:00:00', '10:30:00', '11:00:00',
    '14:00:00', '14:30:00', '15:00:00', '15:30:00', '16:00:00'
  ];

  if (!user) {
    return (
        <div className="flex h-64 items-center justify-center">
            <Loader2 className="h-8 w-8 animate-spin" />
        </div>
    );
  }

  return (
    <div className="container mx-auto p-4 md:p-6">
      {/* Real-time Availability Banner */}
      <Card className="mb-6 bg-blue-50 border-blue-200">
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-semibold text-blue-900">Doctor Availability</h3>
              <p className="text-sm text-blue-700">
                {doctors.length} doctors available
              </p>
            </div>
            <div className="flex items-center space-x-4 text-sm text-blue-700">
              <div className="flex items-center">
                <CheckCircle className="h-4 w-4 mr-1 text-green-600" />
                <span>Available</span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

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
              <Label htmlFor="doctor" className="flex items-center">
                <Stethoscope className="h-4 w-4 mr-2" />
                Select Doctor *
              </Label>
              <Select value={clinicianId} onValueChange={setClinicianId}>
                <SelectTrigger id="doctor">
                  <SelectValue placeholder="Choose a specialist..." />
                </SelectTrigger>
                <SelectContent>
                  {doctors.map((doctor) => (
                    <SelectItem key={doctor.id} value={doctor.id}>
                      <div className="flex items-center justify-between w-full">
                        <div className="flex flex-col flex-1">
                          <span className="font-medium">{doctor.full_name}</span>
                          <span className="text-xs text-gray-500">
                            {doctor.specialization} • {doctor.todayAppointmentCount} appointments today
                          </span>
                        </div>
                        <div className="ml-2">
                          {getAvailabilityBadge(doctor)}
                        </div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-xs text-gray-500 mt-1">
                Select date and time to see availability
              </p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="date" className="flex items-center">
                  <Calendar className="h-4 w-4 mr-2" />
                  Appointment Date *
                </Label>
                <Input 
                  id="date" 
                  type="date" 
                  value={appointmentDate} 
                  onChange={(e) => setAppointmentDate(e.target.value)} 
                  min={new Date().toISOString().split("T")[0]} 
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="time" className="flex items-center">
                  <Clock className="h-4 w-4 mr-2" />
                  Preferred Time *
                </Label>
                <Select id="time" value={appointmentTime} onValueChange={setAppointmentTime}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a time slot" />
                  </SelectTrigger>
                  <SelectContent>
                    {timeSlots.map(slot => (
                      <SelectItem key={slot} value={slot}>
                        {new Date(`1970-01-01T${slot}`).toLocaleTimeString([], { 
                          hour: '2-digit', 
                          minute: '2-digit', 
                          hour12: true 
                        })}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="reason" className="flex items-center">
                <ClipboardList className="h-4 w-4 mr-2" />
                Reason for Visit
              </Label>
              <Textarea 
                id="reason" 
                placeholder="Briefly describe your symptoms or reason for the visit..." 
                value={reason} 
                onChange={(e) => setReason(e.target.value)} 
              />
            </div>

            <Button 
              type="submit" 
              className="w-full bg-[#0A3D62] hover:bg-[#1E5F8B]" 
              disabled={isSubmitting}
            >
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {isSubmitting ? 'Submitting Request...' : 'Request Appointment'}
            </Button>
          </form>
        </CardContent>
        <CardFooter>
          <p className="text-xs text-gray-500 text-center w-full">
            Please note: This is a request. Your appointment will be confirmed by the clinic shortly.
          </p>
        </CardFooter>
      </Card>
    </div>
  );
};

export default BookAppointmentPage;