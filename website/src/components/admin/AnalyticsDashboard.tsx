import React, { useState, useEffect } from 'react';
import { supabase } from '../../services/supabaseClient';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '../ui/dialog';
import { Input } from '../ui/input';
import { toast } from 'sonner';
import { BarChart3, Upload, Brain, TrendingUp, Users, Eye, PieChart as PieIcon, Loader2 } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, PieChart, Pie, Cell, Legend } from 'recharts';

// Mock data for charts that are not yet connected to the database
const scanDistribution = [
  { name: 'CNV', value: 3248, color: '#E74C3C' },
  { name: 'DME', value: 2856, color: '#F39C12' },
  { name: 'Drusen', value: 4102, color: '#9B59B6' },
  { name: 'Normal', value: 5536, color: '#27AE60' }
];
const aiPerformanceData = [
  { model: 'CNV Detection', accuracy: 97.8, sensitivity: 96.2, specificity: 98.4 },
  { model: 'DME Detection', accuracy: 96.2, sensitivity: 94.8, specificity: 97.1 },
  { model: 'Drusen Detection', accuracy: 94.5, sensitivity: 92.1, specificity: 95.8 },
  { model: 'Normal Classification', accuracy: 99.1, sensitivity: 98.7, specificity: 99.3 }
];

export default function AnalyticsDashboard() {
  // --- FIXED: All hooks are now correctly placed INSIDE the component function ---
  const [reportFile, setReportFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [growthData, setGrowthData] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // This useEffect now correctly fetches real-time data for the chart
  useEffect(() => {
    const fetchGrowthData = async () => {
      const { data, error } = await supabase.rpc('get_monthly_growth_stats');
      
      if (error) {
        console.error("Error fetching growth data:", error);
        toast.error("Failed to load platform growth data.");
      } else {
        setGrowthData(data);
      }
      setIsLoading(false);
    };
    fetchGrowthData();
  }, []);

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files.length > 0) {
      setReportFile(event.target.files[0]);
    }
  };

  const handleUploadReport = async () => {
    if (!reportFile) {
      toast.error('Please select a file to upload.');
      return;
    }
    setIsUploading(true);
    try {
      const fileName = `${new Date().toISOString()}-${reportFile.name}`;
      const { error } = await supabase.storage
        .from('reports')
        .upload(fileName, reportFile);

      if (error) throw error;
      
      toast.success('Report uploaded successfully!');
      setReportFile(null);
    } catch (error) {
      toast.error(`Upload failed: ${error.message}`);
    } finally {
      setIsUploading(false);
    }
  };
  
  // This is your original UI, unchanged
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-semibold text-medical-blue">Advanced Analytics</h1>
          <p className="text-muted-foreground">In-depth platform metrics and AI performance analysis</p>
        </div>
        <Dialog>
          <DialogTrigger asChild>
            <Button>
              <Upload className="w-4 h-4 mr-2" />
              Upload Retinal Report
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Upload Report for Advanced Analysis</DialogTitle>
              <DialogDescription>
                Upload a CSV or PDF report to be processed by the analysis engine.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <Input type="file" onChange={handleFileChange} />
              {reportFile && <p className="text-sm text-muted-foreground">Selected: {reportFile.name}</p>}
            </div>
            <Button onClick={handleUploadReport} disabled={isUploading || !reportFile}>
              {isUploading ? <Loader2 className="animate-spin mr-2" /> : <Upload className="mr-2" />}
              {isUploading ? 'Uploading...' : 'Upload and Analyze'}
            </Button>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center"><TrendingUp className="w-5 h-5 mr-2" /> Platform Growth</CardTitle>
            <CardDescription>User registration and scan volume trends</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                {/* --- FIXED: This chart now uses real data from the 'growthData' state --- */}
                <LineChart data={growthData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis allowDecimals={false}/>
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="scans" stroke="#27AE60" strokeWidth={2} name="Scans Analyzed" />
                  <Line type="monotone" dataKey="users" stroke="#0A3D62" strokeWidth={2} name="New Users" />
                  <Line type="monotone" dataKey="doctors" stroke="#E74C3C" strokeWidth={2} name="New Doctors" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center"><PieIcon className="w-5 h-5 mr-2" /> Diagnosis Distribution</CardTitle>
            <CardDescription>Breakdown of all AI-detected retinal conditions</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={scanDistribution} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={100} label>
                    {scanDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>
      
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center"><Brain className="w-5 h-5 mr-2" /> AI Model Performance</CardTitle>
          <CardDescription>Real-time accuracy metrics for each diagnostic model.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Model</TableHead>
                <TableHead className="text-right">Accuracy</TableHead>
                <TableHead className="text-right">Sensitivity</TableHead>
                <TableHead className="text-right">Specificity</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {aiPerformanceData.map((model) => (
                <TableRow key={model.model}>
                  <TableCell className="font-medium">{model.model}</TableCell>
                  <TableCell className="text-right text-green-600 font-semibold">{model.accuracy}%</TableCell>
                  <TableCell className="text-right">{model.sensitivity}%</TableCell>
                  <TableCell className="text-right">{model.specificity}%</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
};