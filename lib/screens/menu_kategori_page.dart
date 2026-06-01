import 'package:flutter/material.dart';

class MenuKategoriPage extends StatelessWidget {
  final List<Map<String, dynamic>> semuaMenu;
  final Map<String, Map<String, dynamic>> keranjang;
  final Function(Map<String, dynamic>, int) onUpdate;
  final List<int> mejaTerisi;

  const MenuKategoriPage({super.key, required this.semuaMenu, required this.keranjang, required this.onUpdate, required this.mejaTerisi});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3E2723),   
          title: const Text("Daftar Menu", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          bottom: const TabBar(labelColor: Color(0xFFD4AF37), unselectedLabelColor: Colors.white54, tabs: [Tab(text: "KUE KERING"), Tab(text: "KUE BASAH")]),
        ),
        body: Column(
          children: [
            Expanded(child: TabBarView(children: [_buildVerticalList('kering'), _buildVerticalList('basah')])),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalList(String kat) {
    final list = semuaMenu.where((m) => m['kategori'] == kat).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: list.length,
      itemBuilder: (c, i) {
        final item = list[i];
        int qty = keranjang[item['nama']]?['qty'] ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
          child: Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              child: Image.network(item['img'], width: 100, height: 110, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.cookie, size: 50, color: Colors.brown)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Rp ${item['harga']}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(item['deskripsi'], maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.2)),
                ]),
              ),
            ),
            Column(children: [
              IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50), size: 28), onPressed: () => onUpdate(item, 1)),
              if (qty > 0) Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
              if (qty > 0) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red, size: 28), onPressed: () => onUpdate(item, -1)),
            ]),
            const SizedBox(width: 8),
          ]),
        );
      },
    );
  }
}