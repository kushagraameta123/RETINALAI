import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
// --- ADDED: Import Supabase for the logout function ---
import { supabase } from '../services/supabaseClient';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Separator } from './ui/separator';
import { Avatar, AvatarFallback } from './ui/avatar';
import { 
  Eye, 
  LayoutDashboard, 
  Users, 
  Calendar, 
  FileText, 
  MessageSquare, 
  Settings, 
  LogOut,
  Stethoscope,
  Brain,
  BarChart3,
  UserPlus,
  Upload,
  Camera,
  Mail,
  Bell,
  ChevronDown,
  Activity,
  Database,
  Cpu,
  Shield,
  Download,
  BookOpen,
  Search
} from 'lucide-react';

// --- CHANGED: Removed the onLogout prop ---
const NavigationSidebar = ({ user, notifications = [] }) => {
  const location = useLocation();
  const navigate = useNavigate();
  const [collapsed, setCollapsed] = useState(false);

  // --- ADDED: The logout handler function that uses Supabase ---
  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/auth');
  };

  const getUserInitials = (name) => {
    return name?.split(' ').map(n => n[0]).join('').toUpperCase() || 'U';
  };

  // (Your navigation items arrays are unchanged)
  const doctorNavItems = [
    { section: 'Overview', items: [ { icon: LayoutDashboard, label: 'Dashboard', path: '/doctor'}, { icon: Activity, label: 'Analytics', path: '/doctor/analytics'} ] },
    { section: 'Patient Care', items: [ { icon: Users, label: 'Patient Management', path: '/doctor/patients'}, { icon: Calendar, label: 'Appointments', path: '/doctor/appointments'}, { icon: Stethoscope, label: 'Analysis Center', path: '/doctor/analysis'}, { icon: FileText, label: 'Medical Reports', path: '/doctor/reports'} ] },
    { section: 'Communication', items: [ { icon: MessageSquare, label: 'Patient Chat', path: '/doctor/chat'}, { icon: Mail, label: 'Email Center', path: '/doctor/email'}, { icon: Brain, label: 'AI Assistant', path: '/doctor/ai-assistant'} ] },
    { section: 'Tools', items: [ { icon: Camera, label: 'OCT Scanner', path: '/doctor/scanner'}, { icon: Upload, label: 'Image Upload', path: '/doctor/upload'} ] }
  ];
  const userNavItems = [
    { section: 'Overview', items: [ { icon: LayoutDashboard, label: 'Dashboard', path: '/user'} ] },
    { section: 'Appointments', items: [ { icon: Calendar, label: 'My Appointments', path: '/user/appointments'}, { icon: UserPlus, label: 'Book Appointment', path: '/user/book-appointment'} ] },
    { section: 'Medical Records', items: [ { icon: FileText, label: 'My Reports', path: '/user/reports'}, { icon: Download, label: 'Download Center', path: '/user/downloads'} ] },
    { section: 'Communication', items: [ { icon: MessageSquare, label: 'Chat with Doctor', path: '/user/chat'} ] },
    { section: 'Resources', items: [ { icon: BookOpen, label: 'Health Education', path: '/user/education'} ] }
  ];
  const adminNavItems = [
    { section: 'Overview', items: [ { icon: LayoutDashboard, label: 'Admin Dashboard', path: '/admin'}, { icon: BarChart3, label: 'System Analytics', path: '/admin/analytics'} ] },
    { section: 'AI/ML Management', items: [ { icon: Brain, label: 'Model Training', path: '/admin/model-training'}, { icon: Cpu, label: 'AI Performance', path: '/admin/ai-performance'}, { icon: Database, label: 'Training Data', path: '/admin/training-data'} ] },
    { section: 'User Management', items: [ { icon: Users, label: 'All Users', path: '/admin/users'}, { icon: Stethoscope, label: 'Doctor Management', path: '/admin/doctors'}, { icon: Shield, label: 'Permissions', path: '/admin/permissions'} ] },
    { section: 'System', items: [ { icon: Activity, label: 'System Health', path: '/admin/system-health'}, { icon: Settings, label: 'Configuration', path: '/admin/configuration'} ] }
  ];

  const getNavItems = () => {
    // --- FIXED: Gets role from user_metadata and uses correct role names ---
    const role = user?.user_metadata?.role;
    switch (role) {
      case 'clinician': return doctorNavItems;
      case 'admin': return adminNavItems;
      case 'patient': return userNavItems;
      default: return [];
    }
  };

  const isActivePath = (path) => {
    return location.pathname === path || (path !== '/user' && path !== '/doctor' && path !== '/admin' && location.pathname.startsWith(path));
  };

  const totalNotifications = notifications.reduce((acc, curr) => acc + (curr.count || 0), 0);

  return (
    <div className={`bg-white border-r border-gray-200 h-screen flex flex-col transition-all duration-300 ${
      collapsed ? 'w-20' : 'w-64'
    }`}>
      {/* Header */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="relative">
            <Eye className="h-8 w-8 text-[#0A3D62]" />
            <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-[#27AE60] rounded-full"></div>
          </div>
          {!collapsed && (
            <div>
              <h1 className="font-semibold text-[#0A3D62]">Retinal-AI</h1>
              <p className="text-xs text-[#6C757D] -mt-1">Medical Platform</p>
            </div>
          )}
        </div>
      </div>

      {/* User Profile */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <Avatar className="h-10 w-10">
            <AvatarFallback className="bg-[#0A3D62] text-white">
              {/* --- FIXED: Uses user_metadata for initials --- */}
              {getUserInitials(user?.user_metadata?.name)}
            </AvatarFallback>
          </Avatar>
          {!collapsed && (
            <div className="flex-1 min-w-0">
              {/* --- FIXED: Uses user_metadata for name --- */}
              <p className="font-medium text-[#0A3D62] truncate">{user?.user_metadata?.name}</p>
              <div className="flex items-center space-x-2">
                <Badge 
                  variant="outline" 
                  className="text-xs border-[#27AE60] text-[#27AE60]"
                >
                  {/* --- FIXED: Uses user_metadata for role --- */}
                  {user?.user_metadata?.role?.toUpperCase()}
                </Badge>
                {totalNotifications > 0 && (
                  <Badge className="bg-[#E74C3C] text-white text-xs">
                    {totalNotifications}
                  </Badge>
                )}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto py-4">
        <nav className="space-y-6">
          {getNavItems().map((section, sectionIndex) => (
            <div key={sectionIndex}>
              {!collapsed && (
                <h3 className="px-4 text-xs font-medium text-[#6C757D] uppercase tracking-wider mb-2">
                  {section.section}
                </h3>
              )}
              <div className="space-y-1 px-2">
                {section.items.map((item, itemIndex) => {
                  const Icon = item.icon;
                  const isActive = isActivePath(item.path);
                  
                  return (
                    <Link
                      key={itemIndex}
                      to={item.path}
                      title={collapsed ? item.label : ''}
                      className={`flex items-center space-x-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                        isActive
                          ? 'bg-[#0A3D62] text-white'
                          : 'text-[#6C757D] hover:bg-[#E3F2FD] hover:text-[#0A3D62]'
                      } ${collapsed ? 'justify-center' : ''}`}
                    >
                      <Icon className="h-5 w-5 flex-shrink-0" />
                      {!collapsed && (
                        <>
                          <span className="flex-1">{item.label}</span>
                          {item.badge && (
                            <Badge 
                              className={`text-xs ${
                                isActive 
                                  ? 'bg-white text-[#0A3D62]' 
                                  : 'bg-[#E74C3C] text-white'
                              }`}
                            >
                              {item.badge}
                            </Badge>
                          )}
                        </>
                      )}
                    </Link>
                  );
                })}
              </div>
              {sectionIndex < getNavItems().length - 1 && !collapsed && (
                <Separator className="my-4 mx-4" />
              )}
            </div>
          ))}
        </nav>
      </div>

      {/* Footer Actions */}
      <div className="p-4 border-t border-gray-200">
        <div className="space-y-2">
          {!collapsed && (
            <Link to="/settings">
              <Button 
                variant="ghost" 
                className="w-full justify-start text-[#6C757D] hover:bg-[#E3F2FD] hover:text-[#0A3D62]"
              >
                <Settings className="h-4 w-4 mr-3" />
                Settings
              </Button>
            </Link>
          )}
          <Button
            variant="ghost"
            // --- FIXED: Calls the new handleLogout function ---
            onClick={handleLogout}
            className={`${
              collapsed ? 'w-full justify-center' : 'w-full justify-start'
            } text-[#E74C3C] hover:bg-[#FADBD8] hover:text-[#E74C3C]`}
            title={collapsed ? 'Logout' : ''}
          >
            <LogOut className={`h-4 w-4 ${collapsed ? '' : 'mr-3'}`} />
            {!collapsed && 'Logout'}
          </Button>
        </div>
      </div>

      {/* Collapse Toggle */}
      <Button
        variant="ghost"
        size="sm"
        onClick={() => setCollapsed(!collapsed)}
        className="absolute -right-3 top-20 bg-white border border-gray-200 rounded-full p-1 hover:bg-[#E3F2FD]"
      >
        <ChevronDown 
          className={`h-4 w-4 transition-transform ${
            collapsed ? 'rotate-90' : '-rotate-90'
          }`} 
        />
      </Button>
    </div>
  );
};

export default NavigationSidebar;



