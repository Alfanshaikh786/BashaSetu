import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Migrant Teacher';

  final List<String> _roles = [
    'Migrant Teacher',
    'ASHA / Healthcare Worker',
    'Field Officer / Researcher',
    'Community Educator',
  ];

  void _handleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Logged in as $_selectedRole (Offline Mode Active)"),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Educator Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text("Bhasha Setu Offline Portal", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: "Role"),
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Teacher ID / Phone Number",
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "PIN / Password",
                    prefixIcon: Icon(Icons.key_outlined, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("Sign In Offline"),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text("Continue as Guest Educator"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
