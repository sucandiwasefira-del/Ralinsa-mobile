import 'package:flutter/material.dart';
//  Pastikan path import LoginPage ini sudah sesuai dengan proyekmu
import 'login_page.dart'; 

class StrukPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const StrukPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List items = data['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Struk"), 
        backgroundColor: const Color(0xFF3E2723), 
        foregroundColor: const Color(0xFFD4AF37),
        actions: [
          // OPTASI 1: Tombol Logout Instan di Pojok Kanan Atas AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout Testing Admin",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView( 
          child: Container(
            width: 340, 
            margin: const EdgeInsets.all(20), 
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              border: Border.all(color: Colors.brown, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                const Text("RALINSA BITES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const Text("Manisnya tak terlupakan", style: TextStyle(fontSize: 12)),
                const Divider(),
                _row("Tanggal", data['tgl']),
                _row("Nama", data['nama']),
                _row("Meja", data['meja']),
                _row("Metode", data['metode']),
                const Divider(),
                
                const Align(alignment: Alignment.centerLeft, child: Text("Pesanan:", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 5),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item["nama"]} x${item["qty"]}', style: const TextStyle(fontSize: 13)),
                      Text('Rp ${item["harga"] * item["qty"]}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )),

                const Divider(),
                _row("TOTAL", "Rp ${data['total']}", b: true),
                const SizedBox(height: 30),
                
                // Tombol Bawaan: Kembali ke Menu Utama
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("KEMBALI KE MENU", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 5),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 5),

                // OPTASI 2: Tombol Logout Merah di Bagian Bawah Struk (Khusus Testing)
                TextButton.icon(
                  icon: const Icon(Icons.logout, size: 16, color: Colors.red),
                  label: const Text("LOGOUT (ADMIN)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String r, {bool b = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      Text(l), 
      Text(r, style: TextStyle(fontWeight: b ? FontWeight.bold : FontWeight.normal)),
    ],
  );
}