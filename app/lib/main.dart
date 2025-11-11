import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:provider/provider.dart';
import 'chatbot_page.dart'; 
import 'appointment_model.dart';
import 'provider_dashboard.dart';
import 'patient_dashboard.dart'; 
import 'profile_setup_page.dart'; 

// IMPORTANT: Replace these with your actual Supabase project URL and Anon Key.
// You can find these in your Supabase project settings under "API".
const String SUPABASE_URL = 'https://ouzglqvtiovjramkjkez.supabase.co'; 
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91emdscXZ0aW92anJhbWtqa2V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2OTU1MzksImV4cCI6MjA3MzI3MTUzOX0.mG_pK1jDOrdl0VhwTIBFjjqfxdyJ2eZv1k4mUcmIjZs';

// --- Color and Style Definitions ---
const Color primaryBlue = Color(0xFF002D62);
const Color accentGreen = Color(0xFF38A169);
const double maxContentWidth = 900.0;
const String signupUrl = 'https://venerable-queijadas-26a404.netlify.app/';

// --- User Role Definition ---
enum UserRole {
  Patient,
  Provider,
  Admin,
}

// Helper to convert role enum to display string
extension UserRoleExtension on UserRole {
  String toDisplayString() {
    switch (this) {
      case UserRole.Patient:
        return 'Patient/User';
      case UserRole.Provider:
        return 'Healthcare Provider';
      case UserRole.Admin:
        return 'Administrator';
    }
  }
}

// Initialize Supabase before running the app
Future<void> main() async {
  // Ensure Flutter is initialized before calling native code (like Supabase init)
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
  } catch (e) {
    // Note: In a real app, handle initialization failure gracefully.
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

// Global accessor for Supabase instance - Getter guarantees access after init
SupabaseClient get supabase => Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire application in the AppointmentProvider
    return ChangeNotifierProvider(
      create: (_) => AppointmentProvider(),
      child: MaterialApp(
        title: 'Retinal-AI Landing Page',
        theme: ThemeData(
          primaryColor: primaryBlue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: primaryBlue,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryBlue,
              side: const BorderSide(color: accentGreen, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          useMaterial3: true,
        ),
        // Use a StreamBuilder to listen for the Supabase Auth state.
        home: StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData && snapshot.data!.session != null) {
              // Redirect all authenticated users to HomePage (which handles role routing and profile check)
              return const HomePage(role: UserRole.Patient); 
            } else {
              return const LandingPage();
            }
          },
        ),
        routes: {
          '/home': (context) => const LandingPage(),
          '/signed_in': (context) => const HomePage(role: UserRole.Patient), 
          '/sign_in': (context) => const SignInPage(),
          '/chat_bot': (context) => const ChatBotPage(),
        },
      ),
    );
  }
}


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Widget _buildContentWrapper(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: child,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Title
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, color: primaryBlue, size: 36),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                    letterSpacing: 1.2,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Retinal-'),
                    TextSpan(text: 'AI', style: TextStyle(color: accentGreen)),
                  ],
                ),
              ),
            ],
          ),
          // Actions: Only Login icon
          Tooltip(
            message: 'Login',
            child: IconButton(
              icon: const Icon(Icons.login, color: primaryBlue, size: 30),
              onPressed: () => Navigator.of(context).pushNamed('/sign_in'),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[300], height: 1.0),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Chip(
          label: const Text(
            'Medical Grade AI',
            style: TextStyle(
              color: accentGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: accentGreen.withOpacity(0.1),
          side: BorderSide.none,
          avatar: const Icon(Icons.verified_outlined, color: accentGreen, size: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        const SizedBox(height: 28),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 38 : 54,
              fontWeight: FontWeight.w900,
              color: primaryBlue.withOpacity(0.95),
              height: 1.15,
              letterSpacing: 1.1,
            ),
            children: const <TextSpan>[
              TextSpan(text: 'AI-Powered Retinal Health\n'),
              TextSpan(text: 'at Your Fingertips', style: TextStyle(color: accentGreen)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Advanced deep learning for early detection of diabetic retinopathy, glaucoma, AMD, and more. Trusted by healthcare professionals worldwide.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4A5568),
              height: 1.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.of(context).pushNamed('/chat_bot');
              },
              label: const Text('Chatbot Analysis'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
              label: const Text('About'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: accentGreen, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ComplianceBadge(
              icon: Icons.check_circle_outline,
              text: 'HIPAA Compliant',
              color: accentGreen,
            ),
            SizedBox(width: 18),
            _ComplianceBadge(
              icon: Icons.shield_outlined,
              text: 'FDA Guidelines',
              color: primaryBlue,
            ),
            SizedBox(width: 18),
            _ComplianceBadge(
              icon: Icons.star_border,
              text: '',
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Advanced Medical AI Diagnostic Features',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Our cutting-edge technology combines GPT-4.1 Vision with specialized medical AI to deliver professional-grade retinal analysis with unparalleled accuracy.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF4A5568),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt,
            color: primaryBlue,
            size: 48,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildContentWrapper(_buildHeroSection(context)),
            _buildContentWrapper(_buildFeatureSection(context)),
          ],
        ),
      ),
    );
  }
}

// Custom widget to keep the Compliance badges clean and reusable
class _ComplianceBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ComplianceBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        if (text.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

// ====================================================================
// ABOUT PAGE WIDGET 
// ====================================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ... (Helper widget _buildAboutFeature remains the same) ...
  Widget _buildAboutFeature({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentGreen, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Retinal-AI',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pioneering the Future of Ophthalmic Diagnosis',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: primaryBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: accentGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Retinal-AI is committed to democratizing access to professional-grade eye health diagnostics using cutting-edge artificial intelligence. We believe early detection is the key to preventing vision loss from conditions like diabetic retinopathy and glaucoma.',
                    style: TextStyle(fontSize: 18, color: Color(0xFF4A5568), height: 1.6),
                  ),
                  const SizedBox(height: 30),
                  _buildAboutFeature(
                    icon: Icons.flash_on,
                    title: 'Speed & Accuracy',
                    description: 'Utilizing proprietary deep learning models to process retinal images in seconds, offering results with clinical-level precision.',
                  ),
                  const SizedBox(height: 20),
                  _buildAboutFeature(
                    icon: Icons.security,
                    title: 'Security & Compliance',
                    description: 'Built from the ground up to meet stringent global healthcare data standards, ensuring patient privacy (HIPAA compliant).',
                  ),
                  const SizedBox(height: 20),
                  _buildAboutFeature(
                    icon: Icons.person_add,
                    title: 'For Healthcare Professionals',
                    description: 'Designed to augment the capabilities of clinicians, providing a powerful screening tool that integrates seamlessly into existing workflows.',
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      child: const Text('Return to Home'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// SIGN IN PAGE WIDGET (New)
// ====================================================================

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // State for role selection
  UserRole _selectedRole = UserRole.Patient;

  // New function to launch the external URL
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showError('Could not launch $urlString');
    }
  }

  // --- Forgot Password Logic ---
  Future<void> _resetPassword(String email) async {
    if (email.trim().isEmpty) return;

    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email!'),
            backgroundColor: accentGreen,
          ),
        );
      }
    } on AuthException catch (e) {
      _showError('Failed to send reset link: ${e.message}');
    } catch (e) {
      _showError('An unexpected error occurred during reset.');
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to receive a password reset link.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: primaryBlue)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            ElevatedButton(
              onPressed: () {
                _resetPassword(emailController.text);
                Navigator.of(dialogContext).pop(); 
              },
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }
  // --- END Forgot Password Logic ---


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper function to show errors
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Handles Sign In (Login)
  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Authenticate with Supabase
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // 2. Successful sign-in, navigate to the authenticated area, passing the selected role
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(role: _selectedRole),
          ),
        );
      }
    } 
    on AuthException catch (e) { 
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred.');
      debugPrint('Auth Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Function to navigate to sign up page with Provider role pre-selected
  void _signUpAsProvider() {
     _launchURL(signupUrl); // Still directs to external signup page
     // Optional: Show a message that they should select "Provider" after signing up.
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register on the website first. You can select the Provider role upon first login.')),
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Access',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 30),

                // Role Selection Dropdown
                DropdownButtonFormField<UserRole>(
                  decoration: InputDecoration(
                    labelText: 'Sign in as',
                    prefixIcon: const Icon(Icons.security, color: primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  initialValue: _selectedRole,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toDisplayString()),
                    );
                  }).toList(),
                  onChanged: (UserRole? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Email Input
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color.fromARGB(255, 243, 4, 4), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up/Registration Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // General User Sign Up
                    TextButton(
                      onPressed: _isLoading ? null : () => _launchURL(signupUrl),
                      child: const Text(
                        "Patient Signup ",
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // NEW: Doctor Registration Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _signUpAsProvider,
                      icon: const Icon(Icons.medical_services, size: 15),
                      label: const Text("Reg as Doctor"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// HOME PAGE WIDGET (The Role Router and Profile Checker)
// ====================================================================

class HomePage extends StatefulWidget {
  final UserRole role; 
  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Doctor?>? _profileCheckFuture;
  
  @override
  void initState() {
    super.initState();
    // Start the asynchronous profile check when the widget initializes
    _profileCheckFuture = _checkProfileStatus();
  }

  Future<Doctor?> _checkProfileStatus() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return null;

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    return await provider.fetchProfile(currentUserId);
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign out failed.')),
        );
      }
    }
  }

  // Helper function to render different dashboard content
  Widget _getDashboardBody(String currentUserId, UserRole role) {
    switch (role) {
      case UserRole.Patient:
        return PatientDashboard(patientId: currentUserId); 
      case UserRole.Provider:
        return ProviderDashboard(doctorId: currentUserId); 
      case UserRole.Admin:
        return const AdminDashboard();
    }
  }

  String _getDashboardTitle(UserRole role) {
    switch (role) {
      case UserRole.Patient:
        return 'Patient Portal Dashboard';
      case UserRole.Provider:
        return 'Healthcare Provider Dashboard';
      case UserRole.Admin:
        return 'System Administrator Panel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      return const Center(child: Text("Authentication error. Please log in again."));
    }

    // Use FutureBuilder to load the correct content based on profile status
    return FutureBuilder<Doctor?>(
      future: _profileCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: Text(_getDashboardTitle(widget.role))), body: const Center(child: CircularProgressIndicator()));
        }

        final profileExists = snapshot.data != null;
        final requiredSetup = !profileExists && (widget.role == UserRole.Provider || widget.role == UserRole.Admin);

        if (requiredSetup) {
          // If profile is missing for a key role, redirect to setup page
          return ProfileSetupPage(role: widget.role);
        }
        
        // If profile exists or user is a Patient (who is not forced into setup)
        return Scaffold(
          appBar: AppBar(
            title: Text(_getDashboardTitle(widget.role)),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _signOut,
              ),
            ],
          ),
          body: _getDashboardBody(currentUserId, widget.role),
        );
      },
    );
  }
}
