import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onStartOrder;
  const DashboardPage({super.key, required this.onStartOrder});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(width: double.infinity, height: double.infinity, decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=800"), fit: BoxFit.cover))),
        Container(width: double.infinity, height: double.infinity, color: Colors.black.withValues(alpha: 0.5)),
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.bakery_dining, size: 80, color: Color(0xFFD4AF37)),
          const Text("Ralinsa Bites", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 42, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("\"Kualitas rasa yang autentik, dipanggang dengan penuh ketulusan untuk momen berharga Anda.\"", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 50),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)), onPressed: onStartOrder, child: const Text("MULAI PESAN")),
        ])),
      ],
    );
  }
}