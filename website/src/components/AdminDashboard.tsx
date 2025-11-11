import React, { useState, useEffect } from 'react';
import { supabase } from '../services/supabaseClient';
import { Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Progress } from './ui/progress';
import { Separator } from './ui/separator';
import {
  LayoutDashboard,
  Users,
  Activity,
  Settings,
  Bell,
  LogOut,
  Monitor,
  BarChart3,
  Shield,
  Eye,
  Stethoscope,
  Brain,
  Loader2 // Import the loader icon
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import UserManagement from './admin/UserManagement';
import AnalyticsDashboard from './admin/AnalyticsDashboard';
import AIModelCenter from './admin/AIModelCenter';

// Define placeholder components for other routes
const SystemHealth = () => <div className="text-center py-12"><Monitor className="w-16 h-16 text-muted-foreground mx-auto mb-4" /><h3 className="text-xl font-semibold mb-2">System Health</h3><p className="text-muted-foreground">System monitoring and health checks coming soon</p></div>;
const SecurityCompliance = () => <div className="text-center py-12"><Shield className="w-16 h-16 text-muted-foreground mx-auto mb-4" /><h3 className="text-xl font-semibold mb-2">Security & Compliance</h3><p className="text-muted-foreground">Security management interface coming soon</p></div>;
const AdminSettings = () => <div className="text-center py-12"><Settings className="w-16 h-16 text-muted-foreground mx-auto mb-4" /><h3 className="text-xl font-semibold mb-2">System Settings</h3><p className="text-muted-foreground">Configuration management interface coming soon</p></div>;

// --- This is your original renderOverview function, converted to a proper component ---
const Overview = ({ user, systemMetrics, usageData, scanDistribution, aiPerformanceData }) => {
    return (
        <div className="space-y-6">
          {/* Header */}
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-2xl font-semibold text-medical-blue">System Overview</h1>
              <p className="text-muted-foreground">Complete platform analytics and performance monitoring</p>
            </div>
            <div className="flex items-center space-x-4">
              <Button variant="outline" size="sm">
                <Bell className="w-4 h-4 mr-2" />
                Alerts ({systemMetrics.pendingApprovals})
              </Button>
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                <div className="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
                System Healthy
              </Badge>
            </div>
          </div>
          
          {/* Key Metrics */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Total Users</CardTitle><Users className="h-4 w-4 text-muted-foreground" /></CardHeader>
              <CardContent><div className="text-2xl font-bold text-medical-blue">{systemMetrics.totalUsers.toLocaleString()}</div><p className="text-xs text-muted-foreground">+12% from last month</p></CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Medical Professionals</CardTitle><Stethoscope className="h-4 w-4 text-muted-foreground" /></CardHeader>
              <CardContent><div className="text-2xl font-bold text-health-green">{systemMetrics.totalDoctors}</div><p className="text-xs text-muted-foreground">+8% from last month</p></CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Total Scans</CardTitle><Eye className="h-4 w-4 text-muted-foreground" /></CardHeader>
              <CardContent><div className="text-2xl font-bold text-accent-red">{systemMetrics.totalScans.toLocaleString()}</div><p className="text-xs text-muted-foreground">+23% from last month</p></CardContent>
            </Card>
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">System Uptime</CardTitle><Activity className="h-4 w-4 text-muted-foreground" /></CardHeader>
              <CardContent><div className="text-2xl font-bold text-medical-blue">{systemMetrics.systemUptime}%</div><p className="text-xs text-muted-foreground">Last 30 days</p></CardContent>
            </Card>
          </div>

          {/* Charts Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader><CardTitle>Platform Growth</CardTitle><CardDescription>User registration and scan volume trends</CardDescription></CardHeader>
              <CardContent><div className="h-80"><ResponsiveContainer width="100%" height="100%"><LineChart data={usageData}><CartesianGrid strokeDasharray="3 3" /><XAxis dataKey="month" /><YAxis /><Tooltip /><Line type="monotone" dataKey="users" stroke="#0A3D62" strokeWidth={2} name="Users" /><Line type="monotone" dataKey="scans" stroke="#27AE60" strokeWidth={2} name="Scans" /><Line type="monotone" dataKey="doctors" stroke="#E74C3C" strokeWidth={2} name="Doctors" /></LineChart></ResponsiveContainer></div></CardContent>
            </Card>
            <Card>
              <CardHeader><CardTitle>Diagnosis Distribution</CardTitle><CardDescription>Breakdown of retinal conditions detected</CardDescription></CardHeader>
              <CardContent><div className="h-80"><ResponsiveContainer width="100%" height="100%"><PieChart><Pie data={scanDistribution} cx="50%" cy="50%" labelLine={false} label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`} outerRadius={80} fill="#8884d8" dataKey="value">{scanDistribution.map((entry, index) => (<Cell key={`cell-${index}`} fill={entry.color} />))}</Pie><Tooltip /></PieChart></ResponsiveContainer></div></CardContent>
            </Card>
          </div>
          {/* ... (rest of your original overview UI) ... */}
        </div>
    );
};

export default function AdminDashboard() {
  const navigate = useNavigate();
  const location = useLocation();
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Your original mock data for analytics
  const systemMetrics = { totalUsers: 2456, totalDoctors: 87, totalScans: 15742, systemUptime: 99.7, activeUsers: 234, pendingApprovals: 12 };
  const usageData = [
    { month: 'Jan', users: 1200, scans: 8500, doctors: 65 }, { month: 'Feb', users: 1450, scans: 9200, doctors: 68 },
    { month: 'Mar', users: 1680, scans: 10100, doctors: 72 }, { month: 'Apr', users: 1890, scans: 11300, doctors: 76 },
    { month: 'May', users: 2100, scans: 12800, doctors: 81 }, { month: 'Jun', users: 2456, scans: 15742, doctors: 87 }
  ];
  const scanDistribution = [
    { name: 'CNV', value: 3248, color: '#E74C3C' }, { name: 'DME', value: 2856, color: '#F39C12' },
    { name: 'Drusen', value: 4102, color: '#9B59B6' }, { name: 'Normal', value: 5536, color: '#27AE60' }
  ];
  const aiPerformanceData = [
    { model: 'CNV Detection', accuracy: 97.8, sensitivity: 96.2, specificity: 98.4 }, { model: 'DME Detection', accuracy: 96.2, sensitivity: 94.8, specificity: 97.1 },
    { model: 'Drusen Detection', accuracy: 94.5, sensitivity: 92.1, specificity: 95.8 }, { model: 'Normal Classification', accuracy: 99.1, sensitivity: 98.7, specificity: 99.3 }
  ];

  useEffect(() => {
    const fetchUser = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      setUser(user);
      setIsLoading(false);
    };
    fetchUser();
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/auth');
  };

  const menuItems = [
    { id: 'overview', label: 'Overview', icon: LayoutDashboard, path: '/admin' },
    { id: 'ai-models', label: 'AI Models', icon: Brain, path: '/admin/ai-models' },
    { id: 'users', label: 'User Management', icon: Users, path: '/admin/users' },
    { id: 'analytics', label: 'Analytics', icon: BarChart3, path: '/admin/analytics' },
    { id: 'system', label: 'System Health', icon: Monitor, path: '/admin/system' },
    { id: 'security', label: 'Security & Compliance', icon: Shield, path: '/admin/security' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/admin/settings' }
  ];

  const handleNavigation = (path) => {
    navigate(path);
  };

  // --- ADDED: This loading check prevents the white screen error ---
  if (isLoading) {
    return (
      <div className="flex h-screen w-full items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-medical-blue" />
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col">
        <div className="p-6 border-b border-gray-200"><div className="flex items-center space-x-3"><div className="w-8 h-8 bg-medical-blue rounded-lg flex items-center justify-center"><Eye className="w-5 h-5 text-white" /></div><div><h2 className="font-semibold text-medical-blue">Retinal-AI Admin</h2><p className="text-xs text-muted-foreground">System Management</p></div></div></div>
        <div className="p-4 border-b border-gray-200"><div className="flex items-center space-x-3"><Avatar className="h-10 w-10"><AvatarImage src={user?.user_metadata?.avatar_url} /><AvatarFallback className="bg-medical-blue text-white">{user?.user_metadata?.name?.split(' ').map(n => n[0]).join('') || 'AD'}</AvatarFallback></Avatar><div className="flex-1"><p className="text-sm font-medium text-medical-blue">{user?.user_metadata?.name || 'System Administrator'}</p><p className="text-xs text-muted-foreground">{user?.email || 'admin@retinal-ai.com'}</p><Badge variant="outline" className="text-xs mt-1">Administrator</Badge></div></div></div>
        <nav className="flex-1 p-4"><div className="space-y-2">{menuItems.map((item) => { const Icon = item.icon; const isActive = location.pathname.startsWith(item.path) && (item.path !== '/admin' || location.pathname === '/admin'); return (<button key={item.id} onClick={() => handleNavigation(item.path)} className={`w-full flex items-center space-x-3 px-3 py-2 rounded-lg text-left transition-colors ${isActive ? 'bg-medical-blue text-white' : 'text-gray-600 hover:bg-gray-100'}`}><Icon className="w-5 h-5" /><span className="text-sm font-medium">{item.label}</span></button>);})}</div></nav>
        <div className="p-4 border-t border-gray-200"><Button variant="ghost" className="w-full justify-start text-gray-600 hover:text-red-600" onClick={handleLogout}><LogOut className="w-4 h-4 mr-2" />Sign Out</Button></div>
      </div>
      
      {/* Main Content */}
      <div className="flex-1 overflow-auto">
        <div className="p-6">
          <Routes>
            <Route path="/" element={
                <Overview 
                    user={user} 
                    systemMetrics={systemMetrics} 
                    usageData={usageData} 
                    scanDistribution={scanDistribution} 
                    aiPerformanceData={aiPerformanceData} 
                />
            } />
            <Route path="/ai-models" element={<AIModelCenter />} />
            <Route path="/users" element={<UserManagement />} />
            <Route path="/analytics" element={<AnalyticsDashboard />} />
            <Route path="/system" element={<SystemHealth />} />
            <Route path="/security" element={<SecurityCompliance />} />
            <Route path="/settings" element={<AdminSettings />} />
          </Routes>
        </div>
      </div>
    </div>
  );
}