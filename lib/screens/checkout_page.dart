import 'package:flutter/material.dart';
import '../api_service.dart';
import 'struk_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<int> mejaTerisi;
  final String username;
  const CheckoutPage({super.key, required this.items, required this.mejaTerisi, required this.username});

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
                        borderColor = const Color(0xFFD4AF37);
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
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      setState(() => loading = true);
                      final now = DateTime.now();
                      final tglFormatted = '${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}';
                      final daftarMenu = widget.items.map((item) => '${item["qty"]}x ${item["nama"]}').join(', ');

                      final data = {
                        'username': widget.username,
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