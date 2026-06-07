import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiwayatPage extends StatefulWidget {
  // Kita memerlukan username untuk memfilter data di Google Sheets
  final String username;
  const RiwayatPage({super.key, required this.username});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List _riwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // URL Web App Google Apps Script kamu
    final String baseUrl = "https://script.google.com/macros/s/AKfycbxtAoCjiJvvqmPbdVackaj08i0KaDcJD3UOkUMchAgvIw7yJtLBBGBBy6CBUgCocJtQ_w/exec";
    
    // Gabungkan URL dengan action dan nama user
    final url = "$baseUrl?action=ambil_riwayat_user&nama=${Uri.encodeComponent(widget.username)}";
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Mengambil array 'data' dari JSON response
          _riwayat = data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error memuat riwayat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pesanan Saya"), 
        backgroundColor: const Color(0xFF3E2723), 
        foregroundColor: const Color(0xFFD4AF37)
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
        : _riwayat.isEmpty 
          ? const Center(child: Text("Belum ada riwayat pesanan.")) 
          : ListView.builder(
              itemCount: _riwayat.length,
              itemBuilder: (c, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.brown),
                  title: Text(_riwayat[i]['menu'] ?? "Menu", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Meja: ${_riwayat[i]['meja']} | ${_riwayat[i]['tgl']}"),
                  trailing: Text("Rp ${_riwayat[i]['total']}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
    );
  }
}