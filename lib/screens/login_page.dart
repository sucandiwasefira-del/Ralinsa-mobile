import 'package:flutter/material.dart';
import '../api_service.dart';
import 'main_navigation.dart';
import 'admin_dashboard_page.dart';
import 'register_page.dart'; // IMPORT BARU UNTUK HALAMAN REGISTER

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Username dan Password tidak boleh kosong!");
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil fungsi login dari ApiService yang terhubung ke Google Sheets
    final respon = await ApiService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (respon['status'] == 'success') {
      String role = respon['role'];
      _showSnackBar("Selamat datang, ${_usernameController.text}!");

      if (!mounted) return;

      // Pembagian Hak Akses (Role-Based Access)
      if (role == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const AdminDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => MainNavigation(username: _usernameController.text.trim())),
        );
      }
    } else {
      _showSnackBar(respon['message'] ?? "Login Gagal!");
    }
  }

  void _showSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Background krem hangat
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bakery_dining, size: 80, color: Color(0xFFD4AF37)),
              const SizedBox(height: 10),
              const Text(
                "Ralinsa Bites",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
              ),
              const Text("Silakan masuk ke akun Anda", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              // Input Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF3E2723)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              
              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF3E2723)),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tombol Masuk
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2723),
                        foregroundColor: const Color(0xFFD4AF37),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _login,
                      child: const Text("MASUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),

              // ========================================================
              // KODE BARU: TOMBOL PINDAH KE HALAMAN DAFTAR AKUN (REGISTER)
              // ========================================================
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Belum punya akun? Daftar di sini",
                  style: TextStyle(
                    color: Color(0xFF3E2723), 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ========================================================
            ],
          ),
        ),
      ),
    );
  }
}