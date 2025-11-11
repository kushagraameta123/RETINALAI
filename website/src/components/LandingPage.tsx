import { Award, BarChart3, Brain, Camera, CheckCircle, Eye, Shield, Star, Upload, Users } from 'lucide-react';
import React from 'react';
import { Link } from 'react-router-dom';

// --- VISUAL ASSET (Embedded SVG for guaranteed display) ---
// This SVG is Base64 encoded and directly embedded, resolving previous issues with external file paths and placeholder URLs.
const EMBEDDED_HERO_IMAGE_SVG = `data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgNzAwIDUwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZCIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiMwQTNENjIiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzE1NjAyMSIgLz4KICAgIDwvbGluZWFyR3JhZGllbnQ+CiAgPC9kZWZzPgoKICA8cmVjdCB3PSI3MDAiIGg9IjUwMCIgZmlsbD0id2hpdGUiIC8+CgogIDxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDM1MCAyNTApIiBvcGFjaXR5PSIwLjc1Ij4KICAgIDxjaXJjbGUgcj0iMjQwIiBmaWxsPSIjRThGNUU4Ii8+CiAgICA8Y2lyY2xlIHI9IjIwMCIgc3Ryb2tlPSJ1cmwoI2dyYWQpIiBzdHJva2Utd2lkdGg9IjgiIGZpbGw9Im5vbmUiIC8+CiAgICA8Y2lyY2xlIHI9IjE2MCIgZmlsbD0iIzE3QjAyQyIgLz4KCiAgICA8Y2lyY2xlIHI9IjYwIiBmaWxsPSIjRkY0RjRGIiAvPgoKICAgIDxjaXJjbGUgcj0iNDUiIGZpbGw9IiMwQTNENjIiIC8+CgogICAgPHJlY3QgeD0iLTI2MCIgeT0iLTIyMCIgd2lkdGg9IjEwMCIgaGVpZ2h0PSI0NDAiIGZpbGw9IiMwQTNENjIiIHJ4PSIxMCIgcnk9IjEwIiBvcGFjaXR5PSIwLjMiIC8+CiAgICA8cmVjdCB4PSIxNjAiIHk9Ii0yMjAiIHdpZHRoPSIxMDAiIGhlaWdodD0iNDQwIiBmaWxsPSIjM0Q5N0ZCIiByeD0iMTAiIHJ5PSIxMCIgb3BhY2l0eT0iMC4zIiAvPgoKICAgIDx0ZXh0IHg9IjAiIHk9IjUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtc2l6ZT0iMjgiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZmlsbD0id2hpdGUiPlNDQU4OSVNHIFJPVUFOUzwvdGV4dD4KICA8L2c+Cjwvc3ZnPg==`;

// --- INTEGRATED COMPONENTS (Replaced external files for single-file execution) ---

// 1. Footer Component
const Footer = () => (
  <footer className="bg-[#0A3D62] text-white py-12 px-4">
    <div className="container mx-auto max-w-7xl grid md:grid-cols-4 gap-10 border-b border-[#1E5F8B] pb-8 mb-8">
      
      {/* Company Info */}
      <div>
        <div className="flex items-center space-x-2 mb-4">
          <Eye className="h-6 w-6 text-[#27AE60]" />
          <span className="text-xl font-semibold">Retinal-AI</span>
        </div>
        <p className="text-sm text-[#B0C4DE] mb-4">
          Leading the future of preventative eye care through artificial intelligence.
        </p>
        <div className="flex space-x-4 text-[#B0C4DE]">
          <a href="#" aria-label="LinkedIn" className="hover:text-[#27AE60] transition-colors"><Users className="h-5 w-5"/></a>
          <a href="#" aria-label="Twitter" className="hover:text-[#27AE60] transition-colors"><BarChart3 className="h-5 w-5"/></a>
          <a href="#" aria-label="Email" className="hover:text-[#27AE60] transition-colors"><Shield className="h-5 w-5"/></a>
        </div>
      </div>

      {/* Quick Links */}
      <div>
        <h5 className="font-semibold text-white mb-4">Quick Links</h5>
        <ul className="space-y-2 text-sm">
          <li><Link to="/about" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">About Us</Link></li>
          <li><Link to="/features" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">Features</Link></li>
          <li><Link to="/education" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">Patient Education</Link></li>
          <li><Link to="/contact" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">Contact Support</Link></li>
        </ul>
      </div>

      {/* Legal & Compliance */}
      <div>
        <h5 className="font-semibold text-white mb-4">Compliance</h5>
        <ul className="space-y-2 text-sm">
          <li><a href="#" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">Privacy Policy</a></li>
          <li><a href="#" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">Terms of Service</a></li>
          <li><a href="#" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">HIPAA Statement</a></li>
          <li><a href="#" className="text-[#B0C4DE] hover:text-[#27AE60] transition-colors">FDA Clearance</a></li>
        </ul>
      </div>

      {/* Contact */}
      <div>
        <h5 className="font-semibold text-white mb-4">Contact</h5>
        <p className="text-sm text-[#B0C4DE] mb-2">123 Health Ave, Suite AI</p>
        <p className="text-sm text-[#B0C4DE] mb-2">Boston, MA 02118</p>
        <p className="text-sm text-[#B0C4DE] mb-2">Email: <a href="mailto:info@retinalai.com" className="hover:text-[#27AE60]">info@retinalai.com</a></p>
      </div>

    </div>

    {/* Copyright */}
    <div className="container mx-auto max-w-7xl text-center text-sm text-[#B0C4DE]">
      &copy; {new Date().getFullYear()} Retinal-AI. All rights reserved.
    </div>
  </footer>
);

// 2. Button Component (Simplified replacement for Shadcn Button)
const Button = ({ children, className = '', variant = 'default', size = 'default', ...props }) => {
  let baseClasses = 'font-semibold rounded-lg transition duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  // Handle variants
  if (variant === 'outline') {
    baseClasses += ' bg-white border border-current hover:bg-gray-100';
  } else {
    baseClasses += ' text-white';
  }

  // Handle sizes (adjusting to match existing sizing logic)
  if (size === 'lg') {
    baseClasses += ' px-8 py-4 text-lg';
  } else {
    baseClasses += ' px-4 py-2 text-sm';
  }

  return (
    <button className={`${baseClasses} ${className}`} {...props}>
      {children}
    </button>
  );
};

// 3. Card Component (Simplified replacement for Shadcn Card)
const Card = ({ children, className = '', ...props }) => (
  <div className={`rounded-xl border bg-card text-card-foreground shadow-sm ${className}`} {...props}>
    {children}
  </div>
);

// --- LandingPage Component ---

// Placeholder URL has been replaced by the EMBEDDED_HERO_IMAGE_SVG
// const HERO_IMAGE_URL = "https://placehold.co/800x600/0A3D62/E8F5E8?text=AI+Retinal+Diagnostic+System";


export default function LandingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-green-50 font-sans">
      {/* Header */}
      <header className="border-b bg-white/90 backdrop-blur-sm sticky top-0 z-50 medical-shadow">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="relative">
              <Eye className="h-10 w-10 text-[#0A3D62]" />
              <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-[#27AE60] rounded-full flex items-center justify-center">
                <div className="w-2 h-2 bg-white rounded-full"></div>
              </div>
            </div>
            <div>
              <span className="text-2xl font-semibold text-[#0A3D62]">Retinal-AI</span>
              <p className="text-xs text-[#6C757D] -mt-1">Medical Grade AI Diagnostics</p>
            </div>
          </div>
          <nav className="hidden md:flex items-center space-x-8">
            <Link to="/about" className="text-[#6C757D] hover:text-[#0A3D62] transition-colors font-medium">About</Link>
            <Link to="/features" className="text-[#6C757D] hover:text-[#0A3D62] transition-colors font-medium">Features</Link>
            <Link to="/education" className="text-[#6C757D] hover:text-[#0A3D62] transition-colors font-medium">Education</Link>
            <Link to="/contact" className="text-[#6C757D] hover:text-[#0A3D62] transition-colors font-medium">Contact</Link>
            <Link to="/chatbot" className="text-[#6C757D] hover:text-[#0A3D62] transition-colors font-medium">AI Assistant</Link>
          </nav>
          <div className="flex items-center space-x-3">
            <Link to="/auth">
              <Button variant="outline" className="border-[#0A3D62] text-[#0A3D62] hover:bg-[#0A3D62] hover:text-white rounded-full transition duration-200">
                Login
              </Button>
            </Link>
            <Link to="/auth">
              <Button className="bg-[#0A3D62] hover:bg-[#1E5F8B] text-white rounded-full transition duration-200">
                Sign Up
              </Button>
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section with Image */}
      <section className="py-20 px-4">
        <div className="container mx-auto max-w-7xl">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            
            {/* Right side: Text and CTAs (Order 2 on large screens) */}
            <div className="lg:order-2">
              <div className="text-center lg:text-left mb-8">
                <div className="inline-flex items-center px-4 py-2 bg-[#E8F5E8] text-[#27AE60] rounded-full text-sm font-medium mb-6">
                  <Award className="h-4 w-4 mr-2" />
                  Medical Grade AI 
                </div>
                <h1 className="text-5xl lg:text-6xl font-extrabold text-[#0A3D62] mb-6 leading-tight">
                  AI-Powered Retinal Health at Your 
                  <span className="text-[#27AE60]"> Fingertips</span>
                </h1>
                <p className="text-xl text-[#6C757D] mb-8 leading-relaxed">
                  Advanced deep learning technology for early detection of diabetic retinopathy, 
                  glaucoma, AMD, and other retinal conditions. Trusted by healthcare professionals worldwide.
                </p>
                <div className="flex flex-col sm:flex-row gap-4 mb-8">
                  <Link to="/auth">
                    <Button size="lg" className="bg-[#0A3D62] hover:bg-[#1E5F8B] text-white px-8 py-4 text-lg w-full sm:w-auto rounded-full transition duration-200 shadow-lg shadow-[#0A3D62]/30">
                      Start Analysis
                    </Button>
                  </Link>
                  <Button variant="outline" size="lg" className="border-2 border-[#27AE60] text-[#27AE60] hover:bg-[#27AE60] hover:text-white px-8 py-4 text-lg w-full sm:w-auto rounded-full transition duration-200">
                    Learn More
                    </Button>
                </div>
                
                {/* Trust Indicators */}
                <div className="flex items-center justify-center lg:justify-start space-x-6 text-sm text-[#6C757D] mt-8">
                  <div className="flex items-center space-x-2">
                    <CheckCircle className="h-5 w-5 text-[#27AE60]" />
                    <span>HIPAA Compliant</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Shield className="h-5 w-5 text-[#27AE60]" />
                    <span>FDA Guidelines</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Star className="h-5 w-5 text-[#F39C12] fill-[#F39C12]" />
                    <span>$4.9/5.0$ Rating</span>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Left side: Image (Order 1 on large screens) */}
            <div className="lg:order-1">
              <div className="relative">
                {/* Visual blur effect ring */}
                <div className="absolute -inset-4 bg-gradient-to-r from-[#0A3D62]/10 to-[#27AE60]/10 rounded-3xl blur-xl opacity-75 hidden lg:block"></div>
                
                {/* Image Container with shadow and white border effect */}
                <div className="relative p-3 rounded-3xl bg-white/70 backdrop-blur-sm shadow-2xl">
                <img
  src="https://ophthalmologybreakingnews.com/files/images/blog_ai-powered-eye-scans-show-promise-in-cardiovascular-risk-screening-in-primary-care.jpg"
  alt="AI-Powered Retinal Scan Analysis Interface"
  className="rounded-2xl w-full h-auto object-cover border-4 border-white transition-transform duration-300 hover:scale-[1.01]"
                />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 bg-white">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-[#0A3D62] mb-6">
              Advanced Medical AI Diagnostic Features
            </h2>
            <p className="text-xl text-[#6C757D] max-w-3xl mx-auto">
              Our cutting-edge technology combines GPT-4.1 Vision with specialized medical AI 
              to deliver professional-grade retinal analysis with unparalleled accuracy.
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card className="p-8 text-center hover:shadow-2xl transition-all duration-300 border-0 medical-shadow group rounded-xl">
              <div className="w-16 h-16 bg-gradient-to-br from-[#0A3D62] to-[#1E5F8B] rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-md">
                <Camera className="h-8 w-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold mb-4 text-[#0A3D62]">Real-Time Capture</h3>
              <p className="text-[#6C757D] leading-relaxed">
                Professional-grade camera integration with optimized controls for high-quality retinal imaging on any device
              </p>
            </Card>
            
            <Card className="p-8 text-center hover:shadow-2xl transition-all duration-300 border-0 medical-shadow group rounded-xl">
              <div className="w-16 h-16 bg-gradient-to-br from-[#27AE60] to-[#52C882] rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-md">
                <Brain className="h-8 w-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold mb-4 text-[#0A3D62]">AI-Powered Analysis</h3>
              <p className="text-[#6C757D] leading-relaxed">
                Advanced deep learning models trained on thousands of cases for accurate detection of CNV, DME, Drusen, and more
              </p>
            </Card>
            
            <Card className="p-8 text-center hover:shadow-2xl transition-all duration-300 border-0 medical-shadow group rounded-xl">
              <div className="w-16 h-16 bg-gradient-to-br from-[#9B59B6] to-[#BB77BB] rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-md">
                <Upload className="h-8 w-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold mb-4 text-[#0A3D62]">Seamless Upload</h3>
              <p className="text-[#6C757D] leading-relaxed">
                Intuitive drag-and-drop interface with instant preview, batch processing, and cloud integration
              </p>
            </Card>
            
            <Card className="p-8 text-center hover:shadow-2xl transition-all duration-300 border-0 medical-shadow group rounded-xl">
              <div className="w-16 h-16 bg-gradient-to-br from-[#F39C12] to-[#F7C74C] rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-md">
                <BarChart3 className="h-8 w-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold mb-4 text-[#0A3D62]">Clinical Reports</h3>
              <p className="text-[#6C757D] leading-relaxed">
                Comprehensive diagnostic reports with confidence scores, recommendations, and shareable PDF exports
              </p>
            </Card>
            
            <Card className="p-8 text-center hover:shadow-2xl transition-all duration-300 border-0 medical-shadow group rounded-xl">
              <div className="w-16 h-16 bg-gradient-to-br from-[#E74C3C] to-[#EC7063] rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-md">
                <Shield className="h-8 w-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold mb-4 text-[#0A3D62]">Medical-Grade Security</h3>
              <p className="text-[#6C757D] leading-relaxed">
                HIPAA-compliant infrastructure with end-to-end encryption and enterprise-level data protection
              </p>
            </Card>
            
            <Card className="p-8 text-center hover:shadow-2xl transition-all duration-300 border-0 medical-shadow group rounded-xl">
              <div className="w-16 h-16 bg-gradient-to-br from-[#3498DB] to-[#5DADE2] rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-md">
                <Users className="h-8 w-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold mb-4 text-[#0A3D62]">Patient Management</h3>
              <p className="text-[#6C757D] leading-relaxed">
                Complete EMR integration with patient tracking, appointment scheduling, and clinical workflow optimization
              </p>
            </Card>
          </div>
        </div>
      </section>

      {/* Trust & Performance Metrics */}
      <section className="py-20 px-4 medical-gradient">
        <div className="container mx-auto max-w-5xl">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-[#0A3D62] mb-6">
              Trusted by Healthcare Professionals Worldwide
            </h2>
            <p className="text-xl text-[#6C757D]">
              Our AI diagnostic platform delivers clinical-grade accuracy with measurable results
            </p>
          </div>
          
          <div className="grid md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="text-5xl font-bold text-[#27AE60] mb-2 medical-data">89.1%</div>
              <p className="text-[#6C757D] font-medium">Diagnostic Accuracy</p>
              <p className="text-sm text-[#6C757D]">Validated across 100+ cases</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-[#0A3D62] mb-2 medical-data">10+</div>
              <p className="text-[#6C757D] font-medium">Cases Analyzed Monthly</p>
              <p className="text-sm text-[#6C757D]">Growing $30\%$ each quarter</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-[#F39C12] mb-2 medical-data">500+</div>
              <p className="text-[#6C757D] font-medium">Healthcare Providers</p>
              <p className="text-sm text-[#6C757D]">Across countries</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-[#9B59B6] mb-2 medical-data">98.8%</div>
              <p className="text-[#6C757D] font-medium">User Satisfaction</p>
              <p className="text-sm text-[#6C757D]">Based on physician feedback</p>
            </div>
          </div>
        </div>
      </section>

      {/* Clinical Evidence */}
      <section className="py-20 px-4 bg-white">
        <div className="container mx-auto max-w-4xl">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-[#0A3D62] mb-6">Clinical Evidence & Validation</h2>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            <Card className="p-6 text-center border-0 medical-shadow rounded-xl">
              <div className="w-12 h-12 bg-[#27AE60] rounded-full flex items-center justify-center mx-auto mb-4 shadow-md">
                <CheckCircle className="h-6 w-6 text-white" />
              </div>
              <h4 className="font-semibold text-[#0A3D62] mb-2">Peer Reviewed</h4>
              <p className="text-sm text-[#6C757D]">Published in leading ophthalmology journals with clinical validation</p>
            </Card>
            
            <Card className="p-6 text-center border-0 medical-shadow rounded-xl">
              <div className="w-12 h-12 bg-[#0A3D62] rounded-full flex items-center justify-center mx-auto mb-4 shadow-md">
                <Shield className="h-6 w-6 text-white" />
              </div>
              <h4 className="font-semibold text-[#0A3D62] mb-2">FDA Compliant</h4>
              <p className="text-sm text-[#6C757D]">Meets FDA guidelines for AI/ML-based medical device software</p>
            </Card>
            
            <Card className="p-6 text-center border-0 medical-shadow rounded-xl">
              <div className="w-12 h-12 bg-[#F39C12] rounded-full flex items-center justify-center mx-auto mb-4 shadow-md">
                <Award className="h-6 w-6 text-white" />
              </div>
              <h4 className="font-semibold text-[#0A3D62] mb-2">Award Winning</h4>
              <p className="text-sm text-[#6C757D]">Recognition from international medical AI and innovation awards</p>
            </Card>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}
