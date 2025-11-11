import {
  Activity,
  Bell,
  Calendar,
  CalendarPlus,
  Clock,
  Download,
  Eye,
  FileText,
  Heart,
  Loader2 // Ensure Loader2 is imported
  ,


  MessageSquare,
  Settings,
  Shield,
  Stethoscope,
  User
} from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { Link, Route, Routes, useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '../services/supabaseClient';
import Footer from './Footer';
import NavigationSidebar from './Navigation';
import UserAppointmentsPage from './UserAppointments';
import BookAppointmentPage from './BookAppointment';
import { Badge } from './ui/badge';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Textarea } from './ui/textarea';
import ChatWithDoctor from './user/ChatWithDoctor';
import DownloadCenter from './user/DownloadCenter';
import HealthEducation from './user/HealthEducation';
import UserReports from './user/UserReports';

// --- This is your original UserDashboardOverview component, unchanged ---
const UserDashboardOverview = ({ user }) => {
  const [dashboardData, setDashboardData] = useState({
    upcomingAppointments: 0, totalReports: 0, pendingAppointments: 0
  });

  useEffect(() => {
    // NOTE: This now uses mock data. You can replace this with real Supabase queries.
    if (user) {
      setDashboardData({
        upcomingAppointments: 2, totalReports: 5, pendingAppointments: 1
      });
    }
  }, [user]);

  const healthStats = [
    { title: "Upcoming Appointments", value: dashboardData.upcomingAppointments, icon: CalendarPlus, color: "text-[#0A3D62]", bgColor: "bg-[#E3F2FD]" },
    { title: "Medical Reports", value: dashboardData.totalReports, icon: FileText, color: "text-[#27AE60]", bgColor: "bg-[#E8F5E8]" },
    { title: "Pending Requests", value: dashboardData.pendingAppointments, icon: Clock, color: "text-[#F39C12]", bgColor: "bg-[#FFF8E1]" },
    { title: "Health Score", value: "Good", icon: Heart, color: "text-[#27AE60]", bgColor: "bg-[#E8F5E8]" }
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-[#0A3D62] mb-2">Welcome back, {user?.user_metadata?.name?.split(' ')[0] || 'User'}</h1>
        <p className="text-[#6C757D]">Manage your appointments and view your medical reports.</p>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {healthStats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <Card key={index} className="medical-shadow border-0">
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-[#6C757D]">{stat.title}</p>
                    <p className="text-3xl font-bold text-[#0A3D62] mt-2">{stat.value}</p>
                  </div>
                  <div className={`${stat.bgColor} p-3 rounded-lg`}>
                    <Icon className={`h-6 w-6 ${stat.color}`} />
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
      <Card className="medical-shadow border-0">
        <CardHeader><CardTitle className="flex items-center"><Activity className="h-5 w-5 mr-2 text-[#0A3D62]" />Quick Actions</CardTitle></CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Link to="/user/book-appointment"><Button className="w-full h-20 flex flex-col items-center justify-center bg-[#0A3D62] hover:bg-[#1E5F8B]"><CalendarPlus className="h-6 w-6 mb-2" /><span>Book Appointment</span></Button></Link>
            <Link to="/user/reports"><Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center border-[#27AE60] text-[#27AE60] hover:bg-[#27AE60] hover:text-white"><FileText className="h-6 w-6 mb-2" /><span>View Reports</span></Button></Link>
            <Link to="/user/downloads"><Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center border-[#F39C12] text-[#F39C12] hover:bg-[#F39C12] hover:text-white"><Download className="h-6 w-6 mb-2" /><span>Download Center</span></Button></Link>
            <Link to="/user/chat"><Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center border-[#9B59B6] text-[#9B59B6] hover:bg-[#9B59B6] hover:text-white"><MessageSquare className="h-6 w-6 mb-2" /><span>Chat with Doctor</span></Button></Link>
          </div>
        </CardContent>
      </Card>
      <div className="grid lg:grid-cols-2 gap-6">
        <UpcomingAppointments userId={user?.id} />
        <RecentReports userId={user?.id} />
      </div>
    </div>
  );
};

// --- This is your original UserProfile component, unchanged ---
const UserProfile = ({ userId }) => (
    <div className="space-y-6">
    <h2 className="text-2xl font-bold text-[#0A3D62]">Profile & Settings</h2>
    <Card className="medical-shadow border-0">
      <CardContent className="p-6">
        <div className="text-center py-12">
          <User className="h-16 w-16 text-[#0A3D62] mx-auto mb-4" />
          <h3 className="text-lg font-medium text-[#0A3D62] mb-2">Profile Management</h3>
          <p className="text-[#6C757D] mb-6">Manage your personal information, preferences, and account settings.</p>
          <div className="grid md:grid-cols-3 gap-4 max-w-3xl mx-auto">
            <div className="p-4 border rounded-lg"><Settings className="h-8 w-8 text-[#27AE60] mx-auto mb-2" /><h4 className="font-medium text-[#0A3D62]">Account Settings</h4><p className="text-sm text-[#6C757D]">Update personal information and preferences</p></div>
            <div className="p-4 border rounded-lg"><Bell className="h-8 w-8 text-[#9B59B6] mx-auto mb-2" /><h4 className="font-medium text-[#0A3D62]">Notifications</h4><p className="text-sm text-[#6C757D]">Manage appointment and health reminders</p></div>
            <div className="p-4 border rounded-lg"><Shield className="h-8 w-8 text-[#F39C12] mx-auto mb-2" /><h4 className="font-medium text-[#0A3D62]">Privacy & Security</h4><p className="text-sm text-[#6C757D]">Control data sharing and security settings</p></div>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
);

// --- This is your original UpcomingAppointments component, unchanged ---
const UpcomingAppointments = ({ userId }) => {
  const [appointments, setAppointments] = useState([]);
  useEffect(() => {
    if (userId) {
      const mockAppointments = [
        { id: 1, doctorName: 'Dr. Evelyn Reed', type: 'Follow-up', appointmentDate: new Date(), appointmentTime: '09:30 AM', status: 'confirmed' },
        { id: 2, doctorName: 'Dr. Marcus Thorne', type: 'New Consultation', appointmentDate: new Date(), appointmentTime: '11:00 AM', status: 'pending' }
      ];
      setAppointments(mockAppointments);
    }
  }, [userId]);
  const getStatusColor = (status) => { return 'bg-gray-100'; };
  return (
    <Card className="medical-shadow border-0">
      <CardHeader><CardTitle className="flex items-center justify-between"><span className="flex items-center"><Calendar className="h-5 w-5 mr-2 text-[#0A3D62]" />Upcoming Appointments</span><Link to="/user/appointments"><Button variant="outline" size="sm">View All</Button></Link></CardTitle></CardHeader>
      <CardContent>
        <div className="space-y-3">
          {appointments.length > 0 ? appointments.map((appointment) => (
            <div key={appointment.id} className="flex items-center justify-between p-3 border rounded-lg">
              <div className="flex-1"><p className="font-medium text-[#0A3D62]">{appointment.doctorName}</p><p className="text-sm text-[#6C757D]">{appointment.type}</p><p className="text-xs text-[#6C757D]">{new Date(appointment.appointmentDate).toLocaleDateString()} at {appointment.appointmentTime}</p></div>
              <Badge className={getStatusColor(appointment.status)}>{appointment.status}</Badge>
            </div>
          )) : (
            <div className="text-center py-8"><Calendar className="h-12 w-12 text-[#6C757D] mx-auto mb-3" /><p className="text-[#6C757D]">No upcoming appointments</p><Link to="/user/book-appointment"><Button className="mt-3 bg-[#0A3D62]">Book Your First Appointment</Button></Link></div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};

// --- This is your original RecentReports component, unchanged ---
const RecentReports = ({ userId }) => {
  const [reports, setReports] = useState([]);
  useEffect(() => {
    if (userId) {
        const mockReports = [{id: 1, findings: {condition: 'Diabetic Retinopathy'}, doctorName: 'Dr. Evelyn Reed', reportDate: new Date()}];
        setReports(mockReports);
    }
  }, [userId]);
  return (
    <Card className="medical-shadow border-0">
      <CardHeader><CardTitle className="flex items-center justify-between"><span className="flex items-center"><FileText className="h-5 w-5 mr-2 text-[#0A3D62]" />Recent Reports</span><Link to="/user/reports"><Button variant="outline" size="sm">View All</Button></Link></CardTitle></CardHeader>
      <CardContent>
        <div className="space-y-3">
          {reports.length > 0 ? reports.map((report) => (
            <div key={report.id} className="flex items-center justify-between p-3 border rounded-lg">
              <div className="flex-1"><p className="font-medium text-[#0A3D62]">{report.findings.condition}</p><p className="text-sm text-[#6C757D]">By {report.doctorName}</p><p className="text-xs text-[#6C757D]">{new Date(report.reportDate).toLocaleDateString()}</p></div>
              <div className="flex items-center space-x-2"><Button size="sm" variant="outline"><Eye className="h-4 w-4" /></Button><Button size="sm" variant="outline"><Download className="h-4 w-4" /></Button></div>
            </div>
          )) : (
            <div className="text-center py-8"><FileText className="h-12 w-12 text-[#6C757D] mx-auto mb-3" /><p className="text-[#6C757D]">No medical reports yet</p><p className="text-sm text-[#6C757D] mt-1">Your reports will appear here after appointments</p></div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};

// --- This is your new, fully functional BookAppointment component ---
// --- This is your new, fully functional BookAppointment component ---
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

  // --- FIXED: This now fetches a REAL list of doctors from your database ---
  useEffect(() => {
    const fetchDoctors = async () => {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name, specialization') // You can select any columns you need
        .eq('role', 'clinician')
        .eq('status', 'active'); // Only show approved, active doctors
      
      if (error) {
        toast.error("Could not fetch the list of doctors.");
        console.error(error);
      } else {
        setDoctors(data);
      }
    };
    fetchDoctors();
  }, []);

  // This function now saves the appointment to your database
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!selectedDoctor) {
      toast.error('Please select a doctor');
      return;
    }
    setIsLoading(true);

    const { error } = await supabase.from('appointments').insert({
      patient_id: user.id,
      doctor_id: selectedDoctor,
      appointment_date: appointmentData.appointmentDate,
      appointment_time: appointmentData.appointmentTime,
      type: appointmentData.type,
      notes: appointmentData.notes,
      status: 'pending'
    });

    if (error) {
      toast.error(`Appointment request failed: ${error.message}`);
    } else {
      toast.success('Appointment request sent successfully!');
      navigate('/user/appointments'); // Redirect to the "My Appointments" page
    }
    setIsLoading(false);
  };

  const appointmentTypes = [
    'Routine Checkup', 'Diabetic Retinopathy Screening', 'Glaucoma Assessment',
    'Follow-up Visit', 'Emergency Consultation', 'Second Opinion'
  ];

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-[#0A3D62] mb-2">Book New Appointment</h2>
        <p className="text-[#6C757D]">Schedule an appointment with one of our specialists.</p>
      </div>
      <Card className="medical-shadow border-0">
        <CardHeader><CardTitle className="flex items-center"><CalendarPlus className="h-5 w-5 mr-2 text-[#0A3D62]" />Appointment Details</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <Label htmlFor="doctor">Select Doctor *</Label>
              <Select value={selectedDoctor} onValueChange={setSelectedDoctor}>
                <SelectTrigger><SelectValue placeholder="Choose a specialist..." /></SelectTrigger>
                <SelectContent>
                  {doctors.map((doctor) => (
                    <SelectItem key={doctor.id} value={doctor.id}>
                      <div className="flex items-center space-x-2">
                        <Stethoscope className="h-4 w-4" />
                        <div>
                          <p>{doctor.full_name}</p>
                          <p className="text-xs text-muted-foreground">{doctor.specialization}</p>
                        </div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div><Label htmlFor="date">Preferred Date *</Label><Input id="date" type="date" required onChange={(e) => setAppointmentData({...appointmentData, appointmentDate: e.target.value})} /></div>
              <div><Label htmlFor="time">Preferred Time *</Label>
            <Select 
              value={appointmentData.appointmentTime} 
              onValueChange={(value) => setAppointmentData({...appointmentData, appointmentTime: value})}>
              <SelectTrigger>
                <SelectValue placeholder="Select a time slot" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="09:00 AM">09:00 AM</SelectItem>
                <SelectItem value="09:30 AM">09:30 AM</SelectItem>
                <SelectItem value="10:00 AM">10:00 AM</SelectItem>
                <SelectItem value="10:30 AM">10:30 AM</SelectItem>
                <SelectItem value="11:00 AM">11:00 AM</SelectItem>
                <SelectItem value="02:00 PM">02:00 PM</SelectItem>
                <SelectItem value="02:30 PM">02:30 PM</SelectItem>
                <SelectItem value="03:00 PM">03:00 PM</SelectItem>
              </SelectContent>
              </Select>
              </div>
              <Label htmlFor="type">Appointment Type *</Label>
              <Select value={appointmentData.type} onValueChange={(value) => setAppointmentData({...appointmentData, type: value})}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>{appointmentTypes.map((type) => (<SelectItem key={type} value={type}>{type}</SelectItem>))}</SelectContent>
              </Select>
            </div>
            <div><Label htmlFor="symptoms">Additional Notes or Symptoms</Label><Textarea id="symptoms" placeholder="Describe any symptoms..." onChange={(e) => setAppointmentData({...appointmentData, notes: e.target.value})} /></div>
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              {isLoading ? 'Submitting...' : 'Submit Appointment Request'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

// --- This is your main UserDashboard component, now with the functional routes ---
export default function UserDashboard() {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);

  useEffect(() => {
    const fetchUser = async () => {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            setUser(user);
        } else {
            navigate('/auth'); // Redirect if no user
        }
    };
    fetchUser();
  }, [navigate]);
  
  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/auth');
  };

  // Display a loader while the user session is being fetched
  if (!user) {
    return (<div className="flex h-screen items-center justify-center"><Loader2 className="h-8 w-8 animate-spin" /></div>);
  }

  return (
    <div className="flex h-screen bg-[#F8F9FA]">
      <NavigationSidebar user={user} onLogout={handleLogout} />
      <div className="flex-1 overflow-hidden flex flex-col">
        <main className="flex-1 p-8 overflow-y-auto">
          {/* --- This is the new centralized routing --- */}
          <Routes>
            <Route path="/" element={<UserDashboardOverview user={user} />} />
            <Route path="/appointments" element={<UserAppointmentsPage user={user} />} />
            <Route path="/book-appointment" element={<BookAppointmentPage user={user} />} />
            <Route path="/reports" element={<UserReports userId={user.id} />} />
            <Route path="/downloads" element={<DownloadCenter userId={user.id} />} />
            <Route path="/chat-doctor" element={<ChatWithDoctor userId={user.id} />} />
            <Route path="/health-education" element={<HealthEducation userId={user.id} />} />
            <Route path="/profile" element={<UserProfile userId={user.id} />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </div>
  );
}