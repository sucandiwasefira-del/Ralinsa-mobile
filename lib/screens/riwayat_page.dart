import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  final List<Map<String, dynamic>> riwayat;
  const RiwayatPage({super.key, required this.riwayat});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Riwayat Pesanan"), backgroundColor: const Color(0xFF3E2723), foregroundColor: const Color(0xFFD4AF37)),
    body: riwayat.isEmpty ? const Center(child: Text("Belum ada riwayat pesanan.")) : ListView.builder(
      itemCount: riwayat.length,
      itemBuilder: (c, i) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.receipt_long, color: Colors.brown),
          title: Text(riwayat[i]['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${riwayat[i]['tgl']} - Meja ${riwayat[i]['meja']}"),
          trailing: Text("Rp ${riwayat[i]['total']}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
      ),
    ),
  );
}