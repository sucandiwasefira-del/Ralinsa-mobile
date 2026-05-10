import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const RalinsaBitesApp());
}

// --- 1. API SERVICE ---
// PERBAIKAN UTAMA: Menggunakan GET request dengan query parameters.
// Alasan: HTTP POST ke Google Apps Script diblokir browser (CORS) saat
// berjalan sebagai Flutter Web. GET request tidak memiliki masalah CORS
// karena GAS sudah mengizinkannya secara default. Solusi ini bekerja
// di semua platform: Android, iOS, dan Web.
class ApiService {
  static const String _gasUrl =
      "https://script.google.com/macros/s/AKfycbxuUXL42lMh4LF_-50x5Q7ffayzHN0bCghWRbEqqlfy8vC39Ky4sjjVMq-P3CtUTBF-/exec";

  static Future<bool> kirimPesanan(Map<String, dynamic> data) async {
    try {
      // Encode semua data sebagai query parameters di URL (GET request).
      // Ini menghindari CORS preflight yang memblokir POST di Flutter Web.
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'nama': data['nama']?.toString() ?? '',
        'meja': data['meja']?.toString() ?? '',
        'total': data['total']?.toString() ?? '',
        'metode': data['metode']?.toString() ?? '',
        'tgl': data['tgl']?.toString() ?? '',
        'menu': data['menu']?.toString() ?? '',
        'status': data['status']?.toString() ?? '',
      });

      // GET request diizinkan lintas-origin oleh Google Apps Script.
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Gagal. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Koneksi Error: $e');
      return false;
    }
  }
}

class RalinsaBitesApp extends StatelessWidget {
  const RalinsaBitesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown, 
        fontFamily: 'Serif',
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      ),
      home: const MainNavigation(),
    );
  }
}

// --- 2. NAVIGASI UTAMA ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Map<String, Map<String, dynamic>> keranjang = {};
  List<Map<String, dynamic>> riwayatPesanan = []; 
  List<int> mejaTerisi = [];

  final List<Map<String, dynamic>> semuaMenu = [
    // KUE KERING (15 Item)
    {'nama': 'Nastar Premium', 'harga': 85000, 'deskripsi': 'Dibuat dengan butter Wisjman melimpah dan selai nanas asli yang asam manis segar.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcxIEAEBcBb9fuMTvkXFjxbLAI6Mn8e1Jysg&s'},
    {'nama': 'Kastengel', 'harga': 90000, 'deskripsi': 'Renyah dan gurih dengan taburan keju yang memberikan aroma khas yang kuat.', 'kategori': 'kering', 'img': 'https://smexpo.pertamina.com/data-smexpo/images/products/3247/galleries/2023040313193591883_1715080733.jpg'},
    {'nama': 'Putri Salju', 'harga': 75000, 'deskripsi': 'Kue kacang mete yang lumer di mulut dengan balutan gula halus dingin seperti salju.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnfawKKjfCDvUip8RfLNGv2psAOo-6FACCZQ&s'},
    {'nama': 'Sagu Keju', 'harga': 70000, 'deskripsi': 'Tekstur super renyah dan lumer seketika, perpaduan sempurna santan kental dan keju.', 'kategori': 'kering', 'img': 'https://static.promediateknologi.id/crop/0x0:0x0/1200x800/webp/photo/p1/1005/2024/03/03/sagu-keju-3346075553.png'},
    {'nama': 'Lidah Kucing', 'harga': 65000, 'deskripsi': 'Kue tipis yang sangat renyah dengan rasa vanilla mentega yang ringan dan manis.', 'kategori': 'kering', 'img': 'https://images.genpi.co/uploads/data/images/lidah%20kucing.jpg'},
    {'nama': 'Chocolate Chip Cookies', 'harga': 60000, 'deskripsi': 'Kue coklat dengan tekstur padat namun rapuh, dipermanis dengan selai coklat  di tengah.', 'kategori': 'kering', 'img': 'https://www.halfbakedharvest.com/wp-content/uploads/2026/01/Really-Good-Chewy-Chocolate-Chip-Cookies-1-scaled.jpg'},
    {'nama': 'Kue Kacang', 'harga': 80000, 'deskripsi': 'Rasa kacang tanah sangrai yang kuat dengan tekstur yang kokoh namun lembut saat digigit.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZXLdroV-rCXTLhq_qZvh1Lj7VMT4NbKpAdA&s'},
    {'nama': 'Kue Coklat Almond', 'harga': 75000, 'deskripsi': 'Kue coklat engan rasa yang memberikan rasa .', 'kategori': 'kering', 'img': 'https://assets.promediateknologi.id/crop/0x0:0x0/1200x600/webp/photo/2023/07/03/Semprit-almond-coklat-3826474212.jpeg'},
    {'nama': 'Kue Bangkit', 'harga': 65000, 'deskripsi': 'Rasa kacang tanah sangrai yang kuat dengan tekstur yang kokoh namun lembut saat digigit.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSynYcBSBRB5UaR8XbMD51EVMWRz5lFCWvYNA&s'},
    {'nama': 'Oatmeal Raisin', 'harga': 85000, 'deskripsi': 'Pilihan lebih sehat dengan gandum utuh dan kismis manis yang kenyal di setiap gigitan.', 'kategori': 'kering', 'img': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400'},
    {'nama': 'Kue Jahe', 'harga': 80000, 'deskripsi': 'kue yang rasa jahe yang khas.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwExvmPC8x3aRHi9v3h1LhJxaCuh36NfmKtw&s'},
    {'nama': 'Kue Pandan Cokelat Chip', 'harga': 85000, 'deskripsi': 'Menggunakan bubuk pandan premium Jepang yang sedikit pahit berpadu manisnya gula.', 'kategori': 'kering', 'img': 'https://static.desty.app/desty-store/xobake/product/e560825e50fc4d83bb23ec43ea0dbae3'},
  
    {'nama': 'Kue Bangkit', 'harga': 55000, 'deskripsi': 'Kue tradisional berbahan sagu yang sangat ringan dan langsung hancur di lidah.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTXJ3gJ7ymqSQurS6-UIJbKapWqbt_fLTq1Tw&s'},
    {'nama': 'Kacang Mente', 'harga': 50000, 'deskripsi': 'Bagian paling enak dari kacang, dibuat tipis dan sangat garing dengan rasa cokelat pekat.', 'kategori': 'kering', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ78AN6MdK1ExYLjpejccJb_H8zMvj0m2vV4g&s'},
    {'nama': 'Cornflakes Butter', 'harga': 65000, 'deskripsi': 'Sereal jagung yang dibalut adonan mentega manis, memberikan sensasi krispi yang beda.', 'kategori': 'kering', 'img': 'https://img.inews.co.id/media/822/files/inews_new/2023/04/10/Resep_Kue_Kering_Cornflakes.jpg'},

    // KUE BASAH (15 Item)
    {'nama': 'Klepon Gula Aren', 'harga': 15000, 'deskripsi': 'Bola ketan kenyal dengan isian gula aren cair yang meledak di mulut, ditabur kelapa parut.', 'kategori': 'basah', 'img': 'https://cdn-jpr.jawapos.com/images/43/2025/08/22/Desain-tanpa-judul-15-148619142.png'},
    {'nama': 'Lapis Legit Slice', 'harga': 25000, 'deskripsi': 'Kue premium dengan belasan lapisan rapi yang kaya akan bumbu spekoek dan mentega pilihan.', 'kategori': 'basah', 'img': 'https://images.unsplash.com/photo-1534353875273-b5887cc1abf5?w=400'},
    {'nama': 'Dadar Gulung', 'harga': 12000, 'deskripsi': 'Kulit pandan hijau lembut yang membungkus unti kelapa manis parutan gula merah.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9WT34ORozifKS-xPbJdgYicOx0aZZOvydJA&s'},
    {'nama': 'Klepon', 'harga': 15000, 'deskripsi': 'Ditaburi dengan wijen diatasnya,renyah ketika digigit dan isinya manis.', 'kategori': 'basah', 'img': 'https://assets.pikiran-rakyat.com/crop/0x0:0x0/720x0/webp/photo/2023/09/09/2401117180.png'},
    {'nama': 'Bika Ambon', 'harga': 20000, 'deskripsi': 'Tekstur berserat yang legit dengan aroma daun jeruk dan serai yang harum menenangkan.', 'kategori': 'basah', 'img': 'https://assets.pikiran-rakyat.com/crop/181x14:1210x628/720x0/webp/photo/2023/02/17/1199872668.png'},
    {'nama': 'Lemper', 'harga': 18000, 'deskripsi': 'Sajian dua lapis, hijau pandan di bawah dan putih santan gurih nan lembut di atas.', 'kategori': 'basah', 'img': 'https://ollella.com/cdn/shop/products/LemperAyam_2.20_2048x.jpg?v=1657181774'},
    {'nama': 'Nagasari', 'harga': 12000, 'deskripsi': 'Kulit kenyal bertabur pisang dengan gigitan yanglembut.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQb4b17ZIW7oSvkTKNJ-ojU5AEqtUN672P9Dw&s'},
    {'nama': 'Getuk', 'harga': 10000, 'deskripsi': 'Kue tepung beras yang lembut dengan ditaburi kelapa yang manis di dalamnya.', 'kategori': 'basah', 'img': 'https://cdn-jpr.jawapos.com/images/43/2025/10/17/20251017_152558_0000-3890483396.png'},
    {'nama': 'Bolu Kukus', 'harga': 12000, 'deskripsi': 'Dengan kukusan yang lembut.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdIUOhtw-HopB9rt_-bc7kRSFgx8scGUEseA&s'},
    {'nama': 'Putu Ayu Pandan', 'harga': 10000, 'deskripsi': 'Kue kukus bertekstur empuk dengan aroma pandan asli dan topping kelapa parut gurih.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvfAeBQaluzjYjZEFK5Sc6WAmki-ENZohYOQ&s'},
    {'nama': 'Kue  Lapis', 'harga': 15000, 'deskripsi': 'Kue yang berlapis dengan rasa yang khas.', 'kategori': 'basah', 'img': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Kue_Lapis.jpg/1280px-Kue_Lapis.jpg'},
    {'nama': 'Kue Cucur', 'harga': 8000, 'deskripsi': 'Kue yang dicampuri gula aren yang dihiasi daun pandan dan rasa manis yang pas.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHvOEEouNJsYBoHUk9qKaiPbsMz3EKhk_9Ng&s'},
    {'nama': 'Talam Pandan', 'harga': 10000, 'deskripsi': 'Perpaduan lapisan hijau pandan yang manis dan lapisan putih santan yang asin gurih.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUDG89E9XpKs6eb1eVAp5AEMuaJGjvj1hIYA&s'},
    {'nama': 'Serabi Solo', 'harga': 15000, 'deskripsi': 'Serabi tipis dengan pinggiran renyah dan bagian tengah yang sangat lembut bersantan.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSASj2Q2Ek5A4n7xhqHcb73-kZBM3Wp1i9HnQ&s'},
    {'nama': 'Semar Mendem', 'harga': 15000, 'deskripsi': 'Varian lemper yang dibalut dengan dadar telur tipis, memberikan rasa yang lebih premium.', 'kategori': 'basah', 'img': 'https://assets.pikiran-rakyat.com/crop/0x80:1208x772/1200x675/photo/2024/04/13/1782033248.png'},
  ];

  void updateQty(Map<String, dynamic> item, int change) {
    setState(() {
      String nama = item['nama'];
      if (change > 0) {
        keranjang.containsKey(nama) ? keranjang[nama]!['qty'] += change : keranjang[nama] = {...item, 'qty': 1};
      } else if (keranjang.containsKey(nama)) {
        keranjang[nama]!['qty'] > 1 ? keranjang[nama]!['qty'] += change : keranjang.remove(nama);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(onStartOrder: () => setState(() => _currentIndex = 1)),
          MenuKategoriPage(semuaMenu: semuaMenu, keranjang: keranjang, onUpdate: updateQty, mejaTerisi: mejaTerisi),
          RiwayatPage(riwayat: riwayatPesanan),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.cake), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
      floatingActionButton: keranjang.isNotEmpty ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD4AF37), 
        foregroundColor: Colors.black, 
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => CheckoutPage(items: keranjang.values.toList(), mejaTerisi: mejaTerisi)));
          if (res != null) {
            setState(() { 
              riwayatPesanan.insert(0, res); 
              keranjang.clear();
              int noMeja = int.parse(res['meja']);
              if (!mejaTerisi.contains(noMeja)) mejaTerisi.add(noMeja);
            });
          }
        },
        label: Text("${keranjang.length} Item", style: const TextStyle(fontWeight: FontWeight.bold)), 
        icon: const Icon(Icons.shopping_cart),
      ) : null,
    );
  }
}

// --- 3. DASHBOARD PAGE ---
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

// --- 4. MENU PAGE ---
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

// --- 5. CHECKOUT PAGE ---
class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<int> mejaTerisi;
  const CheckoutPage({super.key, required this.items, required this.mejaTerisi});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nama = TextEditingController();
  int? selectedMeja;
  String? metode;
  bool loading = false;
  
  bool isBooking = false; 
  List<int> mejaBooking = [3, 7]; // Data contoh meja yang di-booking

  @override
  Widget build(BuildContext context) {
    int total = widget.items.fold(0, (s, i) => s + (i['harga'] as int) * (i['qty'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan"),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: loading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fitur Booking Toggle
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Booking untuk Nanti?", style: TextStyle(fontWeight: FontWeight.bold)),
                        Switch(
                          value: isBooking,
                          activeThumbColor: const Color(0xFFD4AF37),
                          activeTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          onChanged: (v) => setState(() => isBooking = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("STATUS MEJA:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  Row(
                    children: [
                      _legend(Colors.white, "Kosong"),
                      const SizedBox(width: 10),
                      _legend(Colors.red.shade100, "Terisi"),
                      const SizedBox(width: 10),
                      _legend(Colors.orange.shade100, "Booking"),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Grid Meja Kecil (Tanpa Mengubah Logika)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, 
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1,
                    ),
                    itemCount: 16, 
                    itemBuilder: (c, i) {
                      int no = i + 1;
                      bool isFull = widget.mejaTerisi.contains(no);
                      bool isBooked = mejaBooking.contains(no);
                      bool isSelected = selectedMeja == no;

                      Color boxColor = Colors.white;
                      Color textColor = Colors.black;
                      Color borderColor = const Color(0xFFD4AF37);

                      if (isFull) {
                        boxColor = Colors.red.shade100;
                        textColor = Colors.red;
                        borderColor = Colors.red;
                      } else if (isBooked) {
                        boxColor = Colors.orange.shade100;
                        textColor = Colors.orange.shade900;
                        borderColor = Colors.orange;
                      } else if (isSelected) {
                        boxColor = const Color(0xFFD4AF37);
                        textColor = Colors.white;
                      }

                      return GestureDetector(
                        onTap: (isFull || isBooked) ? null : () => setState(() => selectedMeja = no),
                        child: Container(
                          decoration: BoxDecoration(
                            color: boxColor,
                            border: Border.all(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text("$no", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  TextField(controller: _nama, decoration: const InputDecoration(labelText: "Nama Pemesan", border: OutlineInputBorder())),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: metode,
                    hint: const Text("Metode Bayar"),
                    items: ['QRIS', 'Transfer Bank', 'Tunai'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => metode = v),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),

                  if (metode == 'QRIS') _buildQRIS(),
                  if (metode == 'Transfer Bank') _buildBankInfo(),

                  const Divider(height: 40),
                  Text(isBooking ? "TOTAL + BIAYA BOOKING: Rp ${total + 5000}" : "TOTAL TAGIHAN: Rp $total", 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: const Color(0xFF3E2723),
                      foregroundColor: const Color(0xFFD4AF37),
                    ),
                    onPressed: (metode == null || _nama.text.isEmpty || selectedMeja == null) ? null : () async {
                      // Ambil referensi context-dependent objects SEBELUM await apapun
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      setState(() => loading = true);
                      final now = DateTime.now();
                      final tglFormatted = '${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}';
                      final daftarMenu = widget.items.map((item) => '${item["qty"]}x ${item["nama"]}').join(', ');

                      final data = {
                        'nama': _nama.text,
                        'meja': selectedMeja.toString(),
                        'total': isBooking ? total + 5000 : total,
                        'metode': metode,
                        'tgl': tglFormatted,
                        'menu': daftarMenu,
                        'status': isBooking ? 'BOOKING' : 'MAKAN DI TEMPAT',
                        'items': widget.items,
                      };

                      final sukses = await ApiService.kirimPesanan(data);

                      if (!mounted) return;
                      setState(() => loading = false);

                      if (sukses) {
                        await _showSuccessDialog();
                        nav.pop(data);
                        nav.push(MaterialPageRoute(builder: (c) => StrukPage(data: data)));
                      } else {
                        messenger.showSnackBar(const SnackBar(content: Text('Gagal mengirim pesanan. Periksa koneksi internet.')));
                      }
                    },
                    child: Text(isBooking ? "BOOKING SEKARANG" : "PROSES PESANAN SEKARANG", style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
    );
  }

  Widget _legend(Color color, String text) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 9)),
  ]);

  Widget _buildQRIS() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(child: Image.network("https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=RalinsaBitesPayment", width: 140)),
  );

  Widget _buildBankInfo() => Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.brown)),
    child: const Center(child: Text("BCA: 123-456-7890\na/n Sefira Sucandiwa", textAlign: TextAlign.center)),
  );

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text("Pesanan ${isBooking ? 'Booking ' : ''}Berhasil!", textAlign: TextAlign.center),
        actions: [Center(child: TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK")))],
      ),
    );
  }
}

// --- 6. STRUK PAGE ---
class StrukPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const StrukPage({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    // Menarik daftar item dari data pesanan
    List items = data['items'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Struk"), backgroundColor: const Color(0xFF3E2723), foregroundColor: const Color(0xFFD4AF37)),
      body: Center(
        child: SingleChildScrollView( // Tambah scroll agar jika pesanan banyak tetap kelihatan
          child: Container(
            width: 340, margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.brown, width: 2)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("RALINSA BITES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              const Text("Manisnya tak terlupakan", style: TextStyle(fontSize: 12)),
              const Divider(),
              _row("Tanggal", data['tgl']),
              _row("Nama", data['nama']),
              _row("Meja", data['meja']),
              _row("Metode", data['metode']),
              const Divider(),
              
              // --- BAGIAN PENAMBAHAN DAFTAR PESANAN ---
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
              // ----------------------------------------

              const Divider(),
              _row("TOTAL", "Rp ${data['total']}", b: true),
              const SizedBox(height: 30),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("KEMBALI KE MENU", style: TextStyle(color: Colors.brown))),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _row(String l, String r, {bool b = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(r, style: TextStyle(fontWeight: b ? FontWeight.bold : FontWeight.normal))]);
}

// --- 7. RIWAYAT PAGE ---
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