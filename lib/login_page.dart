import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart' as home;
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;
  bool _otpSent = false;
  String? _verificationId;
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar("Please enter a valid phone number with country code (e.g., +1234567890)");
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToHome();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackBar("Verification failed: \${e.message}");
          setState(() => _loading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _loading = false;
          });
          _showSnackBar("OTP sent successfully!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _showSnackBar("OTP timeout. Please try again.");
          setState(() => _loading = false);
        },
      );
    } catch (e) {
      _showSnackBar("Error sending OTP: \$e");
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOTPAndAuthenticate() async {
    if (_otpController.text.isEmpty || _verificationId == null) {
      _showSnackBar("Please enter the OTP");
      return;
    }

    setState(() => _loading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'verifiedPhone': true,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _navigateToHome();
    } catch (e) {
      _showSnackBar("Invalid OTP. Please try again.");
    }

    setState(() => _loading = false);
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);

    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();

    if (!isValid) {
      setState(() => _isLoading = false);
      return;
    }

    _formKey.currentState!.save();

    try {
      final auth = FirebaseAuth.instance;

      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final user = auth.currentUser;
        if (user != null && !user.emailVerified) {
          _showSnackBar("Please verify your email before logging in.");
          await auth.signOut();
          return;
        }

        _navigateToHome();
      } else {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
          _showSnackBar("Verification email sent! Please check your inbox.");
        }

        await auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showSnackBar("This email is already registered. Please log in instead.");
      } else if (e.code == 'invalid-email') {
        _showSnackBar("Invalid email address.");
      } else if (e.code == 'weak-password') {
        _showSnackBar("Password should be at least 6 characters.");
      } else {
        _showSnackBar(e.message ?? 'Authentication failed.');
      }
    } catch (e) {
      _showSnackBar("An unexpected error occurred. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }



  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _navigateToHome();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Google Sign-In failed: ${e.toString()}");
      setState(() => _loading = false);
    } catch (e) {
      _showSnackBar("Google Sign-In failed: ${e.toString()}");
      setState(() => _loading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _loading = true);
    try {
      UserCredential userCredential = await _auth.signInAnonymously();

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'isAnonymous': true,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Failed to continue as guest: ${e.toString()}");
      setState(() => _loading = false);
    } catch (e) {
      _showSnackBar("Failed to continue as guest: ${e.toString()}");
      setState(() => _loading = false);
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showSnackBar("Please enter a valid email");
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return false;
    }
    if (!_isLogin && _nameController.text.isEmpty) {
      _showSnackBar("Please enter your name");
      return false;
    }
    if (!_isLogin && _phoneController.text.isEmpty) {
      _showSnackBar("Please enter your phone number with country code.");
      return false;
    }
    return true;
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => home.HomePage()),
      (route) => false,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showSnackBar("Please enter your email");
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnackBar("Password reset email sent. Please check your inbox.");
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Failed to send reset email: ${e.toString()}");
      setState(() => _loading = false);
    } catch (e) {
      _showSnackBar("Failed to send reset email: ${e.toString()}");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 70,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _isLogin ? "Welcome Back!" : "Create Account",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (!_isLogin) _buildTextField(_nameController, "Full Name", Icons.person),
              _buildTextField(_emailController, "Email", Icons.email),
              _buildTextField(_passwordController, "Password", Icons.lock, obscureText: !_passwordVisible, suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )),
              if (!_isLogin) _buildTextField(_phoneController, "Phone Number (+1234567890)", Icons.phone),

              const SizedBox(height: 24),

              if (!_isLogin && _otpSent) ...[
                _buildTextField(_otpController, "Enter OTP", Icons.numbers),
                const SizedBox(height: 16),
                _buildButton("Verify OTP", _verifyOTPAndAuthenticate),
              ],

              if (!_otpSent || _isLogin) ...[
                _buildButton(_isLogin ? "Login" : "Sign Up", _authenticate),
                const SizedBox(height: 16),
                _buildGoogleSignInButton(),
                const SizedBox(height: 16),
                _buildGuestButton(),
              ],

              if (_isLogin) ...[
                TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _otpSent = false;
                }),
                child: Text(
                  _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

              if (_loading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color.fromARGB(25, 255, 255, 255),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color.fromARGB(128, 255, 255, 255)),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _signInWithGoogle,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.asset(
        'assets/google_logo.png',
        height: 24,
      ),
      label: const Text("Sign in with Google", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildGuestButton() {
    return TextButton(
      onPressed: _loading ? null : _continueAsGuest,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      child: const Text(
        "Continue as Guest",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}