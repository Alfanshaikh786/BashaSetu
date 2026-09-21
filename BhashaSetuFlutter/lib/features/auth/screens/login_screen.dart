import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class StoredUser {
  final String email;
  final String role;
  final String date;

  const StoredUser({required this.email, required this.role, required this.date});

  Map<String, dynamic> toJson() => {'email': email, 'role': role, 'date': date};

  factory StoredUser.fromJson(Map<String, dynamic> json) => StoredUser(
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'Contributor',
        date: json['date'] as String? ?? '',
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _showPassword = false;
  String? _statusMessage;
  bool _isSuccess = false;
  List<StoredUser> _storedUsers = [];
  bool _showStorageData = false;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final rem = prefs.getBool('remember_me') ?? false;
    if (rem) {
      final savedEmail = prefs.getString('saved_email') ?? '';
      final savedPass = prefs.getString('saved_password') ?? '';
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPass;
        _rememberMe = true;
      });
    }

    final usersJson = prefs.getStringList('stored_users') ?? [];
    setState(() {
      _storedUsers = usersJson
          .map((u) => StoredUser.fromJson(jsonDecode(u) as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = "Please fill in all fields.";
        _isSuccess = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }

    if (_isSignUp) {
      // Check if user already exists
      if (_storedUsers.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
        setState(() {
          _statusMessage = "Account with this email already exists.";
          _isSuccess = false;
        });
        return;
      }

      final newUser = StoredUser(
        email: email,
        role: "Contributor",
        date: DateTime.now().toIso8601String().split('T')[0],
      );
      final updated = [..._storedUsers, newUser];
      final encoded = updated.map((u) => jsonEncode(u.toJson())).toList();
      await prefs.setStringList('stored_users', encoded);

      setState(() {
        _storedUsers = updated;
        _statusMessage = "Account created successfully! Redirecting...";
        _isSuccess = true;
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      // Sign in
      setState(() {
        _statusMessage = "Signed in successfully! Welcome back.";
        _isSuccess = true;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // Header Section (Exact Match to Web Screenshot)
                      _buildHeader(),
                      const SizedBox(height: 28),

                      // Login Form Card
                      _buildCard(),
                      const SizedBox(height: 24),

                      // Storage Explorer Badge
                      _buildStorageExplorer(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isSignUp ? "Create Account" : "Welcome Back!",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 10),

        // Underline Bar with Centered Green Accent
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 140, height: 2, color: const Color(0xFFE2E8F0)),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF249144),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          _isSignUp
              ? "Sign up to save translations and contribute"
              : "Please sign in to your account",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Alert
                if (_statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isSuccess ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                          size: 16,
                          color: _isSuccess ? const Color(0xFF249144) : const Color(0xFFB91C1C),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isSuccess ? const Color(0xFF14532D) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Address
                const Text(
                  "Email Address",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                    hintText: "your@email.com",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                const Text(
                  "Password",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                    hintText: "••••••••",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: const Color(0xFF249144),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _rememberMe = val ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("Remember me", style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password recovery: please contact administrator at alfanshaikh902@gmail.com"),
                            backgroundColor: Color(0xFF249144),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF249144)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF249144), Color(0xFF1E7E34)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF249144).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp ? "Create Account" : "Sign In",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSignUp ? "Already have an account? " : "Don't have an account? ",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _statusMessage = null;
                    });
                  },
                  child: Text(
                    _isSignUp ? "Sign in" : "Sign up",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF249144)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageExplorer() {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showStorageData = !_showStorageData),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage_rounded, size: 14, color: Color(0xFF249144)),
              const SizedBox(width: 6),
              Text(
                "Offline Persistence: ${_storedUsers.length} Stored Accounts",
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        if (_showStorageData) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ACCOUNTS SAVED IN DEVICE STORAGE:",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155), letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                if (_storedUsers.isEmpty)
                  const Text("No local accounts stored yet.", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))
                else
                  ..._storedUsers.map((u) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.email, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                Text("Role: ${u.role}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text("Stored", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
