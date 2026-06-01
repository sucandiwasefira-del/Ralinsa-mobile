import 'package:flutter/material.dart';
import '../api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  void _prosesRegister() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Semua kolom harus diisi!");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Konfirmasi password tidak cocok!");
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil fungsi register aman dari ApiService
    final respon = await ApiService.register(username, password);

    setState(() => _isLoading = false);

    if (respon['status'] == 'success') {
      _showSnackBar("Registrasi Berhasil! Silakan Login.");
      if (!mounted) return;
      Navigator.pop(context); // Kembali ke halaman login
    } else {
      _showSnackBar(respon['message'] ?? "Registrasi Gagal!");
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
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        foregroundColor: const Color(0xFF3E2723),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.app_registration, size: 70, color: Color(0xFFD4AF37)),
              const SizedBox(height: 10),
              const Text(
                "Daftar Akun Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
              ),
              const Text("Bergabunglah dengan Ralinsa Bites", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              // Input Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username Baru",
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF3E2723)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              
              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: _isObscure1,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF3E2723)),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure1 ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isObscure1 = !_isObscure1),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Input Konfirmasi Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isObscure2,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3E2723)),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure2 ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isObscure2 = !_isObscure2),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tombol Daftar
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2723),
                        foregroundColor: const Color(0xFFD4AF37),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _prosesRegister,
                      child: const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}