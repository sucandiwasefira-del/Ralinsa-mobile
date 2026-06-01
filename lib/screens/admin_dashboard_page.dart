import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api_service.dart';
import 'login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _tipeFilter = "Mingguan";
  List<double> _chartData = [0, 0, 0, 0, 0, 0, 0];
  List<dynamic> _riwayatPesanan = [];
  List<String> _labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  bool _isLoading = true;
  double _totalPendapatan = 0;

  @override
  void initState() {
    super.initState();
    _muatDataLaporan();
  }

  void _muatDataLaporan() async {
    setState(() => _isLoading = true);
    
    try {
      Map<String, dynamic> responRaw;

      if (_tipeFilter == "Harian") {
        responRaw = await ApiService.ambilDataHarian();
        _labels = ['Pagi', 'Siang', 'Sore', 'Malam'];
      } else if (_tipeFilter == "Mingguan") {
        responRaw = await ApiService.ambilDataPenjualan();
        _labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      } else if (_tipeFilter == "Bulanan") {
        responRaw = await ApiService.ambilDataBulanan();
        _labels = ['W1', 'W2', 'W3', 'W4'];
      } else {
        responRaw = await ApiService.ambilDataTahunan();
        _labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      }

      // Proteksi 1: Pastikan data 'chart' ada dan tidak kosong
      List<double> hasilChart = [];
      if (responRaw.containsKey('chart') && responRaw['chart'] != null) {
        for (var element in responRaw['chart']) {
          hasilChart.add(double.tryParse(element.toString()) ?? 0.0);
        }
      }

      // Jika data chart kosong, sesuaikan panjangnya dengan label agar tidak error fl_chart
      if (hasilChart.isEmpty) {
        hasilChart = List<double>.filled(_labels.length, 0.0);
      }

      double total = hasilChart.fold(0, (sum, item) => sum + item);

      // ============================================================
      // PENYARING DATA KOSONG / ANTI-STRIP (-)
      // ============================================================
      List<dynamic> listMentah = responRaw['riwayat'] ?? [];
      List<dynamic> listBersih = [];

      for (var item in listMentah) {
        String nama = item['nama']?.toString().trim() ?? "";
        double totalHarga = double.tryParse(item['total'].toString()) ?? 0.0;

        // Hanya masukkan data yang punya nama valid (bukan strip atau kosong) dan harga > 0
        if (nama.isNotEmpty && nama != "-" && totalHarga > 0) {
          listBersih.add(item);
        }
      }

      setState(() {
        _chartData = hasilChart;
        _riwayatPesanan = listBersih; // Menampilkan data yang sudah bersih saja
        _totalPendapatan = total;
        _isLoading = false; 
      });

    } catch (e) {
      debugPrint("Error saat memproses data dashboard: $e");
      setState(() {
        _chartData = List<double>.filled(_labels.length, 0.0);
        _riwayatPesanan = [];
        _totalPendapatan = 0;
        _isLoading = false; 
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar dari Dashboard Admin Toko Ralinsa?"),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup Dialog
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (c) => const LoginPage())
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _tombolFilter(String tipe) {
    bool isSelected = _tipeFilter == tipe;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF3E2723),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () {
        setState(() { _tipeFilter = tipe; });
        _muatDataLaporan();
      },
      child: Text(tipe, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text("Dashboard Admin ($_tipeFilter)", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF3E2723),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _muatDataLaporan),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Total Pendapatan
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Pendapatan ($_tipeFilter)", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(
                          "Rp ${_totalPendapatan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Deretan Tombol Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _tombolFilter("Harian"),
                      _tombolFilter("Mingguan"),
                      _tombolFilter("Bulanan"),
                      _tombolFilter("Tahunan"),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text("Grafik Omset Penjualan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                  const SizedBox(height: 15),

                  // Kotak Grafik Batang
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEFEBE9))),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _totalPendapatan > 0 ? null : 500000,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= _labels.length || value.toInt() < 0) return const Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(_labels[value.toInt()], style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text('0');
                                return Text('${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 9));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(_chartData.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: _chartData[index],
                                color: const Color(0xFFD4AF37),
                                width: _tipeFilter == "Tahunan" ? 7 : 14,
                                borderRadius: BorderRadius.circular(3),
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // BAGIAN LIST RIWAYAT PESANAN
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Color(0xFF3E2723)),
                      const SizedBox(width: 8),
                      const Text("Pesanan Terbaru (5 Terakhir)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _riwayatPesanan.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Belum ada pesanan masuk", style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _riwayatPesanan.length,
                          itemBuilder: (context, index) {
                            var item = _riwayatPesanan[index];
                            double totalHarga = double.tryParse(item['total'].toString()) ?? 0.0;
                            
                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFEFEBE9),
                                  child: Text(
                                    item['meja']?.toString() ?? "-",
                                    style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['nama']?.toString() ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                    Text(
                                      "Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Menu: ${item['menu'] ?? '-'}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Via: ${item['metode'] ?? '-'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          Text("${item['hari'] ?? '-'}, ${item['timestamp'] ?? '-'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}