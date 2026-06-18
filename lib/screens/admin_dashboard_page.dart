import 'package:flutter/material.dart';
import '../api_service.dart';
import 'login_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html; 

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

  int _totalMenuTerpesan = 0;
  int _totalOrangBooking = 0;
  int _tunaiCount = 0;
  int _qrisCount = 0;
  int _transferCount = 0;

  @override
  void initState() {
    super.initState();
    _muatDataLaporan();
  }

  void _muatDataLaporan() async {
    setState(() => _isLoading = true);
    
    try {
      Map<String, dynamic> responRaw;
      List<String> labelDefault = [];

      if (_tipeFilter == "Harian") {
        responRaw = await ApiService.ambilDataHarian();
      } else if (_tipeFilter == "Mingguan") {
        responRaw = await ApiService.ambilDataPenjualan();
        labelDefault = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      } else if (_tipeFilter == "Bulanan") {
        responRaw = await ApiService.ambilDataBulanan();
        labelDefault = ['W1', 'W2', 'W3', 'W4'];
      } else {
        responRaw = await ApiService.ambilDataTahunan();
        labelDefault = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      }

      List<double> hasilChart = [];
      if (responRaw.containsKey('chart') && responRaw['chart'] != null) {
        for (var element in responRaw['chart']) {
          hasilChart.add(double.tryParse(element.toString()) ?? 0.0);
        }
      }

      List<dynamic> listMentah = responRaw['riwayat'] ?? [];
      List<dynamic> listBersih = [];

      int menuCount = 0;
      int bookingCount = 0;
      int tunai = 0;
      int qris = 0;
      int transfer = 0;
      
      Map<String, double> akumulasiHarian = {};

      for (var item in listMentah) {
        String nama = item['nama']?.toString().trim() ?? "";
        double totalHarga = double.tryParse(item['total'].toString()) ?? 0.0;
        String metode = item['metode']?.toString().toLowerCase() ?? "";
        String hariItem = item['hari']?.toString() ?? item['tanggal']?.toString() ?? "-";

        if (nama.isNotEmpty && nama != "-" && totalHarga > 0) {
          listBersih.add(item);
          
          if (_tipeFilter == "Harian") {
            if (akumulasiHarian.containsKey(hariItem)) {
              akumulasiHarian[hariItem] = akumulasiHarian[hariItem]! + totalHarga;
            } else {
              akumulasiHarian[hariItem] = totalHarga;
            }
          }
          
          bookingCount++;
          menuCount += (int.tryParse(item['qty']?.toString() ?? "1") ?? 1);
          
          if (metode.contains("tunai")) {
            tunai++;
          } else if (metode.contains("qris")) {
            qris++;
          } else if (metode.contains("transfer")) {
            transfer++;
          }
        }
      }

      List<String> labelFinal = [];
      List<double> chartFinal = [];

      if (_tipeFilter == "Harian") {
        akumulasiHarian.forEach((hari, totalOmset) {
          labelFinal.add(hari);
          chartFinal.add(totalOmset);
        });

        if (labelFinal.isEmpty) {
          labelFinal = ["Belum ada data"];
          chartFinal = [0.0];
        }
      } else {
        labelFinal = labelDefault;
        chartFinal = hasilChart;
        if (chartFinal.isEmpty || chartFinal.length < labelFinal.length) {
          chartFinal = List<double>.filled(labelFinal.length, 0.0);
          if (hasilChart.isNotEmpty) {
            for (int i = 0; i < hasilChart.length; i++) {
              if (i < chartFinal.length) chartFinal[i] = hasilChart[i];
            }
          }
        }
      }

      double total = chartFinal.fold(0, (sum, item) => sum + item);

      setState(() {
        _chartData = chartFinal;
        _riwayatPesanan = listBersih;
        _labels = labelFinal; 
        _totalPendapatan = total;
        
        _totalMenuTerpesan = menuCount;
        _totalOrangBooking = bookingCount;
        _tunaiCount = tunai;
        _qrisCount = qris;
        _transferCount = transfer;
        
        _isLoading = false; 
      });

    } catch (e) {
      debugPrint("Error data dashboard: $e");
      setState(() {
        _chartData = [0.0];
        _riwayatPesanan = [];
        _labels = ["Gagal memuat"];
        _totalPendapatan = 0;
        _isLoading = false; 
      });
    }
  }

  // 1. FUNGSI CETAK LAPORAN BERDASARKAN FILTER YANG AKTIF
  Future<void> _cetakLaporanPDF() async {
    try {
      final pdf = pw.Document();

      final gayaHeader = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white);
      final gayaData = pw.TextStyle(fontSize: 9, color: PdfColors.black);
      final gayaTotal = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black);

      List<dynamic> dataLaporanAktif = _riwayatPesanan; 
      double totalPendapatanAktif = _totalPendapatan;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 30,
            marginTop: 30,
            marginLeft: 25,
            marginRight: 25,
          ),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text("LAPORAN RINCIAN PENJUALAN TOKO RALINSA BITES", 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(child: pw.Text("Manisnya Tak Terlupakan", style: const pw.TextStyle(fontSize: 10))),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text("Periode Laporan: $_tipeFilter", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 15),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(130),
                  4: const pw.FixedColumnWidth(30),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(85),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF3E2723)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("No", style: gayaHeader))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Hari/Tgl", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Pelanggan", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Menu Dipesan", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("Qty", style: gayaHeader))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Metode", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Total", style: gayaHeader))),
                    ],
                  ),
                  
                  if (dataLaporanAktif.isEmpty)
                    pw.TableRow(
                      children: [
                        pw.Container(), pw.Container(), pw.Container(),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Center(child: pw.Text("Tidak ada data transaksi pada periode ini", style: gayaData)),
                        ),
                        pw.Container(), pw.Container(), pw.Container(),
                      ]
                    )
                  else
                    ...List.generate(dataLaporanAktif.length, (index) {
                      var item = dataLaporanAktif[index];
                      double totalHarga = double.tryParse(item['total'].toString()) ?? 0.0;
                      String formattedTotal = "Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                      
                      final warnaBaris = index % 2 == 0 ? PdfColors.grey100 : PdfColors.white;

                      return pw.TableRow(
                        children: [
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("${index + 1}", style: gayaData))),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['hari'] ?? item['tanggal'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['nama'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['menu'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(item['qty']?.toString() ?? "1", style: gayaData))),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['metode'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(formattedTotal, style: gayaData))),
                        ],
                      );
                    }),

                  pw.TableRow(
                    children: [
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("TOTAL OMSET:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      ),
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            "Rp ${totalPendapatanAktif.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                            style: gayaTotal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  "Dicetak otomatis melalui Sistem Manajemen Keuangan Admin Ralinsa Bites", 
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)
                ),
              )
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);

    } catch (e) {
      debugPrint("Gagal mencetak PDF Detail Keuangan: $e");
    }
  }

  // 2. FUNGSI CETAK LAPORAN GABUNGAN (SEMUA TRANSAKSI)
  Future<void> _cetakLaporanGabunganPDF() async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
    );

    Map<String, dynamic> responRaw;
    try {
      responRaw = await ApiService.ambilSemuaTransaksi();
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading dialog
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil data dari server: $e")),
        );
      }
      return;
    }

    try {
      List<dynamic> listMentah = responRaw['riwayat'] ?? [];
      List<dynamic> semuaDataGabungan = [];
      double totalSemuaPendapatan = 0;

      for (var item in listMentah) {
        String nama = item['nama']?.toString().trim() ?? "";
        double totalHarga = double.tryParse(item['total'].toString()) ?? 0.0;
        if (nama.isNotEmpty && nama != "-" && totalHarga > 0) {
          semuaDataGabungan.add(item);
          totalSemuaPendapatan += totalHarga;
        }
      }

      final pdf = pw.Document();

      final gayaHeader = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white);
      final gayaData = pw.TextStyle(fontSize: 9, color: PdfColors.black);
      final gayaTotal = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 30,
            marginTop: 30,
            marginLeft: 25,
            marginRight: 25,
          ),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text("LAPORAN GABUNGAN PENJUALAN TOKO RALINSA BITES", 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(child: pw.Text("Manisnya Tak Terlupakan", style: const pw.TextStyle(fontSize: 10))),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text("Periode: Akumulasi Semua Transaksi Masuk", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 15),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(130),
                  4: const pw.FixedColumnWidth(30),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(85),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF3E2723)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("No", style: gayaHeader))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Hari/Tgl", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Pelanggan", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Menu Dipesan", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("Qty", style: gayaHeader))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Metode", style: gayaHeader)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Total", style: gayaHeader))),
                    ],
                  ),
                  
                  if (semuaDataGabungan.isEmpty)
                    pw.TableRow(
                      children: [
                        pw.Container(), pw.Container(), pw.Container(),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Center(child: pw.Text("Belum ada data transaksi yang masuk", style: gayaData)),
                        ),
                        pw.Container(), pw.Container(), pw.Container(),
                      ]
                    )
                  else
                    ...List.generate(semuaDataGabungan.length, (index) {
                      var item = semuaDataGabungan[index];
                      double totalHarga = double.tryParse(item['total'].toString()) ?? 0.0;
                      String formattedTotal = "Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                      
                      final warnaBaris = index % 2 == 0 ? PdfColors.grey100 : PdfColors.white;

                      return pw.TableRow(
                        children: [
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("${index + 1}", style: gayaData))),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['hari'] ?? item['tanggal'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['nama'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['menu'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(item['qty']?.toString() ?? "1", style: gayaData))),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Text(item['metode'] ?? "-", style: gayaData)),
                          pw.Container(color: warnaBaris, padding: const pw.EdgeInsets.all(6), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(formattedTotal, style: gayaData))),
                        ],
                      );
                    }),

                  pw.TableRow(
                    children: [
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(color: PdfColors.grey300, child: pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(""))),
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("TOTAL GABUNGAN:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      ),
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            "Rp ${totalSemuaPendapatan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                            style: gayaTotal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  "Dicetak otomatis melalui Sistem Manajemen Keuangan Admin Ralinsa Bites", 
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)
                ),
              )
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);

    } catch (e) {
      debugPrint("Gagal mencetak PDF Gabungan: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuka laporan gabungan: $e")),
      );
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
                Navigator.of(context).pop();
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

  Widget _indicatorCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: const Color(0xFFEFEBE9))
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3E2723), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                ],
              ),
            )
          ],
        ),
      ),
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white), 
                onPressed: _cetakLaporanPDF,
                tooltip: "Cetak Laporan Periode Terpilih",
              ),
              IconButton(
                icon: const Icon(Icons.analytics, color: Colors.yellow), 
                onPressed: _cetakLaporanGabunganPDF,
                tooltip: "Cetak Laporan Gabungan Semua",
              ),
            ],
          ),
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

                  Row(
                    children: [
                      _indicatorCard("Menu Terpesan", "$_totalMenuTerpesan Porsi", Icons.restaurant_menu),
                      const SizedBox(width: 10),
                      _indicatorCard("Total Booking", "$_totalOrangBooking Orang", Icons.book_online),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _indicatorCard("Tunai", "$_tunaiCount Kali", Icons.money),
                      const SizedBox(width: 8),
                      _indicatorCard("QRIS", "$_qrisCount Kali", Icons.qr_code_2),
                      const SizedBox(width: 8),
                      _indicatorCard("Transfer", "$_transferCount Kali", Icons.account_balance_wallet_outlined),
                    ],
                  ),
                  const SizedBox(height: 25),

                  Text(
                    _tipeFilter == "Harian" ? "Tabel Rincian Omset Per Hari" : "Tabel Rincian Omset Laporan", 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFEBE9)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF3E2723)),
                        columns: [
                          DataColumn(
                            label: Text(
                              _tipeFilter == "Harian" ? "Hari" : "Periode/Waktu", 
                              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const DataColumn(label: Text('Omset Pendapatan', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))),
                        ],
                        rows: List.generate(_chartData.length, (index) {
                          double omset = _chartData[index];
                          return DataRow(cells: [
                            DataCell(Text(_labels[index], style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text(
                              "Rp ${omset.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                            )),
                          ]);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

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