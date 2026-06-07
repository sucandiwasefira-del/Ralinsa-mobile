import 'package:flutter/material.dart';
import 'login_page.dart'; // Sesuaikan dengan lokasi file login_page.dart kamu

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
          // TOMBOL LOGOUT SEKARANG DI POJOK KANAN ATAS (SESUAI LINGKARAN)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout Admin",
            onPressed: () {
              // Dialog konfirmasi supaya tidak salah klik
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Apakah Anda yakin ingin keluar?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text("Ya, Logout", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
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
                
                // TOMBOL DI DALAM KERTAS HANYA "KEMBALI KE MENU" SAJA
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("KEMBALI KE MENU", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
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