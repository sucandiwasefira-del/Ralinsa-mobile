import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'menu_kategori_page.dart';
import 'riwayat_page.dart';
import 'checkout_page.dart';

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
    {'nama': 'Klepon Gula Aren', 'harga': 15000, 'deskripsi': 'Bola ketan kenyal dengan isian gula aren cair yang meledak di mulut, ditabur kelapa parut.', 'kategori': 'basah', 'img': 'https://cdn-jpr.jawapos.com/images/43/2025/08/22/Desain-tanpa-judul-15-148619142.png'},
    {'nama': 'Lapis Legit Slice', 'harga': 25000, 'deskripsi': 'Kue premium dengan belasan lapisan rapi yang kaya akan bumbu spekoek dan mentega pilihan.', 'kategori': 'basah', 'img': 'https://images.unsplash.com/photo-1534353875273-b5887cc1abf5?w=400'},
    {'nama': 'Dadar Gulung', 'harga': 12000, 'deskripsi': 'Kulit pandan hijau lembut yang membungkus unti kelapa manis parutan gula merah.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9WT34ORozifKS-xPbJdgYicOx0aZZOvydJA&s'},
    {'nama': 'Klepon', 'harga': 15000, 'deskripsi': 'Ditaburi dengan wijen diatasnya,renyah ketika digigit dan isinya manis.', 'kategori': 'basah', 'img': 'https://assets.pikiran-rakyat.com/crop/0x0:0x0/720x0/webp/photo/2023/09/09/2401117180.png'},
    {'nama': 'Bika Ambon', 'harga': 20000, 'deskripsi': 'Tekstur berserat yang legit dengan aroma daun jeruk dan serai yang harum menenangkan.', 'kategori': 'basah', 'img': 'https://assets.pikiran-rakyat.com/crop/181x14:1210x628/720x0/webp/photo/2023/02/17/1199872668.png'},
    {'nama': 'Lemper', 'harga': 18000, 'deskripsi': 'Sajian dua lapis, hijau pandan di bawah dan putih santan gurih nan lembut di atas.', 'kategori': 'basah', 'img': 'https://ollella.com/cdn/shop/products/LemperAyam_2.20_2048x.jpg?v=1657181774'},
    {'nama': 'Nagasari', 'harga': 12000, 'deskripsi': 'Kulit kenyal bertabur pisang dengan gigitan yanglembut.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQb4b17ZIW7oSvkTKNJ-ojU5AEqtUN672P9Dw&s'},
    {'nama': 'Getuk', 'harga': 10000, 'deskripsi': 'Kue tepung beras yang lembut dengan ditaburi kelapa yang manis di dalamnya.', 'kategori': 'basah', 'img': 'https://cdn-jpr.jawapos.com/images/43/2025/10/17/20251017_152558_0000-3890483396.png'},
    {'nama': 'Bolu Kukus', 'harga': 12000, 'deskripsi': 'With kukusan yang lembut.', 'kategori': 'basah', 'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdIUOhtw-HopB9rt_-bc7kRSFgx8scGUEseA&s'},
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