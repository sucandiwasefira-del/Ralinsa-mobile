import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL Web App Google Apps Script Ralinsa Bites
  static const String _gasUrl = "https://script.google.com/macros/s/AKfycbwCloPxQmrpHdMHwHGgG-qej7rPUFxM4ay81FRD8JD93hSTnXyabTKUtsyGRhX_AiSO/exec";
  // =======================================================
  // 1. FUNGSI LOGIN
  // =======================================================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'login',
        'username': username,
        'password': password,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Gagal terhubung ke server'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // =======================================================
  // 2. FUNGSI REGISTER
  // =======================================================
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'register',
        'username': username,
        'password': password,
        'role': 'Pelanggan', // Otomatis mendaftar sebagai Pelanggan
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Gagal terhubung ke server'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // =======================================================
  // 3. FUNGSI KIRIM PESANAN (UTS ASLI)
  // =======================================================
  static Future<bool> kirimPesanan(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'username': data['username']?.toString() ?? '',
        'nama': data['nama']?.toString() ?? '',
        'meja': data['meja']?.toString() ?? '',
        'total': data['total']?.toString() ?? '',
        'metode': data['metode']?.toString() ?? '',
        'tgl': data['tgl']?.toString() ?? '', 
        'menu': data['menu']?.toString() ?? '',
        'status': data['status']?.toString() ?? '',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        return resData['status'] == 'success';
      } else {
        debugPrint('Gagal. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Koneksi Error: $e');
      return false;
    }
  }

  // =======================================================
  // 3b. FUNGSI AMBIL RIWAYAT PESANAN PER USER
  // =======================================================
  static Future<List<Map<String, dynamic>>> ambilRiwayatUser(String username) async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'ambil_riwayat_user',
        'username': username,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['data'] != null) {
          return List<Map<String, dynamic>>.from(resData['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error ambil riwayat: $e');
      return [];
    }
  }


  // =======================================================
  // 4. FUNGSI AMBIL DATA HARIAN + RIWAYAT PESANAN
  // =======================================================
  static Future<Map<String, dynamic>> ambilDataHarian() async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'ambil_harian',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'chart': [0.0, 0.0, 0.0, 0.0], 'riwayat': []};
      }
    } catch (e) {
      return {'chart': [0.0, 0.0, 0.0, 0.0], 'riwayat': []};
    }
  }

  // =======================================================
  // 5. FUNGSI AMBIL DATA MINGGUAN + RIWAYAT PESANAN
  // =======================================================
  static Future<Map<String, dynamic>> ambilDataPenjualan() async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'ambil_penjualan',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'chart': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 'riwayat': []};
      }
    } catch (e) {
      return {'chart': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 'riwayat': []};
    }
  }

  // =======================================================
  // 6. FUNGSI AMBIL DATA BULANAN + RIWAYAT PESANAN
  // =======================================================
  static Future<Map<String, dynamic>> ambilDataBulanan() async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'ambil_bulanan',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'chart': [0.0, 0.0, 0.0, 0.0], 'riwayat': []};
      }
    } catch (e) {
      return {'chart': [0.0, 0.0, 0.0, 0.0], 'riwayat': []};
    }
  }

  // =======================================================
  // 7. FUNGSI AMBIL DATA TAHUNAN + RIWAYAT PESANAN
  // =======================================================
  static Future<Map<String, dynamic>> ambilDataTahunan() async {
    try {
      final uri = Uri.parse(_gasUrl).replace(queryParameters: {
        'action': 'ambil_tahunan',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'chart': List<double>.filled(12, 0.0), 'riwayat': []};
      }
    } catch (e) {
      return {'chart': List<double>.filled(12, 0.0), 'riwayat': []};
    }
  }
}