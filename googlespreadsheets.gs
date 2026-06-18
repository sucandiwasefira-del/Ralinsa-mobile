function doGet(e) {
  var ss;
  try {
    var action = e.parameter ? e.parameter.action : null;
    
    // 1. Dapatkan Spreadsheet (Coba Active dulu, lalu ID default, jika gagal buat database baru)
    try {
      ss = SpreadsheetApp.getActiveSpreadsheet();
    } catch (err) {}
    
    if (!ss) {
      var defaultId = "1_YHgjU8S5IMwgV-M3WwfBqyNaQ8yLg112ka15z9lFM";
      try {
        ss = SpreadsheetApp.openById(defaultId);
      } catch (err) {
        // Cek apakah ada file database lama atau buat baru otomatis
        ss = SpreadsheetApp.create("Ralinsa Bites Database");
      }
    }
    
    // 2. Setup Sheet secara otomatis jika belum ada / baru dibuat
    // Ganti nama default Sheet1 jika ada
    var defaultSheet = ss.getSheetByName("Sheet1") || ss.getSheetByName("Sheet 1");
    if (defaultSheet && !getSheetIgnoreCase(ss, "Users")) {
      defaultSheet.setName("Users");
    }
    
    var usersSheet = getSheetIgnoreCase(ss, "Users");
    if (!usersSheet) {
      usersSheet = ss.insertSheet("Users");
    }
    
    // Pastikan header Users ada
    var usersData = usersSheet.getDataRange().getValues();
    if (!usersData || usersData.length === 0 || !usersData[0][0]) {
      usersSheet.appendRow(["username", "password", "role"]);
      usersSheet.appendRow(["admin", "admin123", "Admin"]);
      usersSheet.appendRow(["sefira", "user123", "Pelanggan"]);
    }
    
    var pesananSheet = getSheetIgnoreCase(ss, "pesanan");
    if (!pesananSheet) {
      pesananSheet = ss.insertSheet("pesanan");
      pesananSheet.appendRow(["Timestamp", "Username", "Nama Pemesan", "No. Meja", "Total (Rp)", "Metode Bayar", "Tanggal Pesan", "Menu Dipesan", "Status"]);
    }
    
    // ==================== 1. FUNGSI LOGIN ====================
    if (action == "login") {
      var usernameInput = e.parameter.username ? e.parameter.username.trim() : "";
      var passwordInput = e.parameter.password ? e.parameter.password.trim() : "";
      
      var data = usersSheet.getDataRange().getValues();
      
      // Looping data user mulai dari baris kedua
      for (var i = 1; i < data.length; i++) {
        var uSheet = data[i][0] ? data[i][0].toString().trim() : "";
        var pSheet = data[i][1] ? data[i][1].toString().trim() : "";
        var rSheet = data[i][2] ? data[i][2].toString().trim() : "Pelanggan";
        
        if (uSheet === usernameInput && pSheet === passwordInput) {
          return responseJson({
            "status": "success",
            "username": uSheet,
            "role": rSheet
          }, ss);
        }
      }
      
      return responseJson({
        "status": "failed",
        "message": "Username atau password salah"
      }, ss);
    }
    
    // ==================== 2. FUNGSI REGISTER ====================
    if (action == "register") {
      var usernameInput = e.parameter.username ? e.parameter.username.trim() : "";
      var passwordInput = e.parameter.password ? e.parameter.password.trim() : "";
      var roleInput = e.parameter.role ? e.parameter.role.trim() : "Pelanggan";
      
      if (!usernameInput || !passwordInput) {
        return responseJson({"status": "error", "message": "Username dan password tidak boleh kosong"}, ss);
      }
      
      var data = usersSheet.getDataRange().getValues();
      for (var i = 1; i < data.length; i++) {
        var uSheet = data[i][0] ? data[i][0].toString().trim() : "";
        if (uSheet.toLowerCase() === usernameInput.toLowerCase()) {
          return responseJson({"status": "error", "message": "Username sudah terdaftar"}, ss);
        }
      }
      
      usersSheet.appendRow([usernameInput, passwordInput, roleInput]);
      return responseJson({"status": "success", "message": "Registrasi berhasil"}, ss);
    }
    
    // ==================== 3. FUNGSI RIWAYAT PESANAN PER USER ====================
    if (action == "ambil_riwayat_user") {
      var usernameInput = e.parameter.username ? e.parameter.username.trim() : "";
      var namaInput = e.parameter.nama ? e.parameter.nama.trim() : "";
      
      var data = pesananSheet.getDataRange().getValues();
      if (!data || data.length <= 1) {
        return responseJson({"data": []}, ss);
      }
      
      var headers = data[0].map(function(h) { return h.toString().toLowerCase().trim(); });
      
      var idxUsername = headers.indexOf("username");
      var idxNama = headers.indexOf("nama pemesan");
      if (idxNama === -1) idxNama = headers.indexOf("nama pesanan");
      
      var idxMenu = headers.indexOf("menu dipesan");
      var idxMeja = headers.indexOf("no. meja");
      if (idxMeja === -1) idxMeja = headers.indexOf("no.meja");
      
      var idxTgl = headers.indexOf("tanggal pesan");
      if (idxTgl === -1) idxTgl = headers.indexOf("tanggal pesanan");
      
      var idxTotal = headers.indexOf("total (rp)");
      if (idxTotal === -1) idxTotal = headers.indexOf("total(rp)");
      
      var idxStatus = headers.indexOf("status");
      
      var hasilRiwayat = [];
      
      for (var i = 1; i < data.length; i++) {
        var usernameDiSheet = idxUsername !== -1 && data[i][idxUsername] ? data[i][idxUsername].toString().trim() : "";
        var namaDiSheet = idxNama !== -1 && data[i][idxNama] ? data[i][idxNama].toString().trim() : "";
        
        var cocok = false;
        if (usernameInput && usernameDiSheet.toLowerCase() === usernameInput.toLowerCase()) {
          cocok = true;
        } else if (!usernameDiSheet && namaInput && namaDiSheet.toLowerCase() === namaInput.toLowerCase()) {
          cocok = true;
        }
        
        if (cocok) {
          var tanggalTeks = idxTgl !== -1 ? data[i][idxTgl] : "";
          if (tanggalTeks instanceof Date) {
            tanggalTeks = Utilities.formatDate(tanggalTeks, Session.getScriptTimeZone(), "dd-MM-yyyy HH:mm");
          } else {
            tanggalTeks = tanggalTeks.toString();
          }
          
          hasilRiwayat.push({
            "nama": idxNama !== -1 && data[i][idxNama] ? data[i][idxNama].toString() : "-",
            "menu": idxMenu !== -1 && data[i][idxMenu] ? data[i][idxMenu].toString() : "-",
            "tgl": tanggalTeks,
            "meja": idxMeja !== -1 ? data[i][idxMeja].toString() : "-",
            "total": idxTotal !== -1 ? data[i][idxTotal].toString() : "0",
            "status": idxStatus !== -1 ? data[i][idxStatus].toString() : ""
          });
        }
      }
      
      hasilRiwayat.reverse();
      return responseJson({"data": hasilRiwayat}, ss);
    }
    
    // ==================== 4. FUNGSI LAPORAN UNTUK DASHBOARD ADMIN ====================
    if (action == "ambil_harian" || action == "ambil_penjualan" || action == "ambil_bulanan" || action == "ambil_tahunan" || action == "ambil_semua") {
      var data = pesananSheet.getDataRange().getValues();
      if (!data || data.length <= 1) {
        var chartLenEmpty = 4;
        if (action == "ambil_penjualan") chartLenEmpty = 7;
        else if (action == "ambil_tahunan") chartLenEmpty = 12;
        else if (action == "ambil_semua") chartLenEmpty = 1;
        var chartEmpty = [];
        for (var k = 0; k < chartLenEmpty; k++) chartEmpty.push(0);
        return responseJson({"chart": chartEmpty, "riwayat": []}, ss);
      }
      
      var headers = data[0].map(function(h) { return h.toString().toLowerCase().trim(); });
      
      var idxNama = headers.indexOf("nama pemesan");
      if (idxNama === -1) idxNama = headers.indexOf("nama pesanan");
      
      var idxMenu = headers.indexOf("menu dipesan");
      var idxMeja = headers.indexOf("no. meja");
      if (idxMeja === -1) idxMeja = headers.indexOf("no.meja");
      
      var idxTgl = headers.indexOf("tanggal pesan");
      if (idxTgl === -1) idxTgl = headers.indexOf("tanggal pesanan");
      
      var idxTotal = headers.indexOf("total (rp)");
      if (idxTotal === -1) idxTotal = headers.indexOf("total(rp)");
      
      var idxMetode = headers.indexOf("metode bayar");
      var idxStatus = headers.indexOf("status");
      
      var riwayatList = [];
      var hariIni = new Date();
      
      var chartLen = 4; // default harian
      if (action == "ambil_penjualan") chartLen = 7;
      else if (action == "ambil_bulanan") chartLen = 4;
      else if (action == "ambil_tahunan") chartLen = 12;
      else if (action == "ambil_semua") chartLen = 1;
      
      var chartData = [];
      for (var i = 0; i < chartLen; i++) chartData.push(0);
      
      for (var i = 1; i < data.length; i++) {
        var row = data[i];
        var namaVal = idxNama !== -1 ? row[idxNama].toString() : "-";
        var menuVal = idxMenu !== -1 ? row[idxMenu].toString() : "-";
        var mejaVal = idxMeja !== -1 ? row[idxMeja].toString() : "-";
        var totalVal = idxTotal !== -1 ? parseFloat(row[idxTotal]) || 0 : 0;
        var metodeVal = idxMetode !== -1 ? row[idxMetode].toString() : "-";
        var statusVal = idxStatus !== -1 ? row[idxStatus].toString() : "-";
        
        var tglObj = null;
        if (idxTgl !== -1 && row[idxTgl]) {
          if (row[idxTgl] instanceof Date) {
            tglObj = row[idxTgl];
          } else {
            tglObj = parseDateString(row[idxTgl].toString());
          }
        }
        
        if (!tglObj) continue;
        
        var tanggalTeks = Utilities.formatDate(tglObj, Session.getScriptTimeZone(), "dd-MM-yyyy HH:mm");
        var hariNama = getIndonesianDayName(tglObj.getDay());
        var formattedTime = Utilities.formatDate(tglObj, Session.getScriptTimeZone(), "HH:mm");
        
        var matchesFilter = false;
        if (action == "ambil_harian") {
          if (isSameDay(hariIni, tglObj)) {
            matchesFilter = true;
            var hour = tglObj.getHours();
            if (hour >= 6 && hour < 12) chartData[0] += totalVal;
            else if (hour >= 12 && hour < 18) chartData[1] += totalVal;
            else if (hour >= 18 && hour < 21) chartData[2] += totalVal;
            else chartData[3] += totalVal;
          }
        } else if (action == "ambil_penjualan") {
          var startOfWeek = getStartOfWeek(hariIni);
          var endOfWeek = new Date(startOfWeek);
          endOfWeek.setDate(endOfWeek.getDate() + 6);
          endOfWeek.setHours(23, 59, 59, 999);
          
          if (tglObj >= startOfWeek && tglObj <= endOfWeek) {
            matchesFilter = true;
            var dayIdx = tglObj.getDay() - 1;
            if (dayIdx < 0) dayIdx = 6;
            chartData[dayIdx] += totalVal;
          }
        } else if (action == "ambil_bulanan") {
          if (tglObj.getMonth() === hariIni.getMonth() && tglObj.getFullYear() === hariIni.getFullYear()) {
            matchesFilter = true;
            var date = tglObj.getDate();
            var weekIdx = Math.floor((date - 1) / 7);
            if (weekIdx > 3) weekIdx = 3;
            chartData[weekIdx] += totalVal;
          }
        } else if (action == "ambil_tahunan") {
          if (tglObj.getFullYear() === hariIni.getFullYear()) {
            matchesFilter = true;
            var monthIdx = tglObj.getMonth();
            chartData[monthIdx] += totalVal;
          }
        } else if (action == "ambil_semua") {
          matchesFilter = true;
        }
        
        if (matchesFilter) {
          var orderItem = {
            "nama": namaVal,
            "menu": menuVal,
            "meja": mejaVal,
            "total": totalVal,
            "metode": metodeVal,
            "status": statusVal,
            "hari": hariNama,
            "tanggal": tanggalTeks,
            "timestamp": formattedTime
          };
          riwayatList.push(orderItem);
        }
      }
      
      riwayatList.reverse();
      
      return responseJson({
        "chart": chartData,
        "riwayat": riwayatList
      }, ss);
    }
    
    // ==================== 5. DEFAULT ACTION: SIMPAN PESANAN ====================
    if (!action || action == "simpan_pesanan") {
      var usernameInput = e.parameter.username ? e.parameter.username.trim() : "";
      var namaInput = e.parameter.nama ? e.parameter.nama.trim() : "";
      var mejaInput = e.parameter.meja ? e.parameter.meja.trim() : "";
      var totalInput = e.parameter.total ? e.parameter.total.trim() : "0";
      var metodeInput = e.parameter.metode ? e.parameter.metode.trim() : "";
      var tglInput = e.parameter.tgl ? e.parameter.tgl.trim() : "";
      var menuInput = e.parameter.menu ? e.parameter.menu.trim() : "";
      var statusInput = e.parameter.status ? e.parameter.status.trim() : "MAKAN DI TEMPAT";
      
      var data = pesananSheet.getDataRange().getValues();
      var headers = data[0].map(function(h) { return h.toString().toLowerCase().trim(); });
      
      var idxTimestamp = headers.indexOf("timestamp");
      var idxUsername = headers.indexOf("username");
      var idxNama = headers.indexOf("nama pemesan");
      if (idxNama === -1) idxNama = headers.indexOf("nama pesanan");
      
      var idxMeja = headers.indexOf("no. meja");
      if (idxMeja === -1) idxMeja = headers.indexOf("no.meja");
      
      var idxTotal = headers.indexOf("total (rp)");
      if (idxTotal === -1) idxTotal = headers.indexOf("total(rp)");
      
      var idxMetode = headers.indexOf("metode bayar");
      var idxTgl = headers.indexOf("tanggal pesan");
      if (idxTgl === -1) idxTgl = headers.indexOf("tanggal pesanan");
      
      var idxMenu = headers.indexOf("menu dipesan");
      var idxStatus = headers.indexOf("status");
      
      // Jika kolom Username belum ada, sisipkan kolom tersebut di samping Timestamp (kolom ke-2)
      if (idxUsername === -1) {
        pesananSheet.insertColumnAfter(1);
        pesananSheet.getRange(1, 2).setValue("Username");
        
        // Reload headers & indices
        data = pesananSheet.getDataRange().getValues();
        headers = data[0].map(function(h) { return h.toString().toLowerCase().trim(); });
        
        idxTimestamp = headers.indexOf("timestamp");
        idxUsername = headers.indexOf("username");
        idxNama = headers.indexOf("nama pemesan");
        if (idxNama === -1) idxNama = headers.indexOf("nama pesanan");
        idxMeja = headers.indexOf("no. meja");
        if (idxMeja === -1) idxMeja = headers.indexOf("no.meja");
        idxTotal = headers.indexOf("total (rp)");
        if (idxTotal === -1) idxTotal = headers.indexOf("total(rp)");
        idxMetode = headers.indexOf("metode bayar");
        idxTgl = headers.indexOf("tanggal pesan");
        if (idxTgl === -1) idxTgl = headers.indexOf("tanggal pesanan");
        idxMenu = headers.indexOf("menu dipesan");
        idxStatus = headers.indexOf("status");
      }
      
      var newRow = new Array(headers.length);
      var timestamp = new Date();
      
      if (idxTimestamp !== -1) newRow[idxTimestamp] = timestamp;
      if (idxUsername !== -1) newRow[idxUsername] = usernameInput;
      if (idxNama !== -1) newRow[idxNama] = namaInput;
      if (idxMeja !== -1) newRow[idxMeja] = mejaInput;
      if (idxTotal !== -1) newRow[idxTotal] = totalInput;
      if (idxMetode !== -1) newRow[idxMetode] = metodeInput;
      if (idxTgl !== -1) newRow[idxTgl] = tglInput || Utilities.formatDate(timestamp, Session.getScriptTimeZone(), "dd-MM-yyyy HH:mm");
      if (idxMenu !== -1) newRow[idxMenu] = menuInput;
      if (idxStatus !== -1) newRow[idxStatus] = statusInput;
      
      pesananSheet.appendRow(newRow);
      return responseJson({"status": "success", "message": "Pesanan berhasil disimpan"}, ss);
    }
  } catch (error) {
    return responseJson({
      "status": "error",
      "message": "Server-side script crash: " + error.toString()
    }, ss);
  }
}

function getSheetIgnoreCase(ss, name) {
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    if (sheets[i].getName().toLowerCase() === name.toLowerCase()) {
      return sheets[i];
    }
  }
  return null;
}

function responseJson(obj, ss) {
  if (ss) {
    obj["spreadsheet_id"] = ss.getId();
    obj["spreadsheet_name"] = ss.getName();
    obj["spreadsheet_url"] = ss.getUrl();
  }
  return ContentService.createTextOutput(JSON.stringify(obj))
                       .setMimeType(ContentService.MimeType.JSON);
}

function parseDateString(str) {
  try {
    var parts = str.split(" ");
    var dateParts = parts[0].split("-");
    var timeParts = parts[1] ? parts[1].split(":") : [0, 0];
    
    var day = parseInt(dateParts[0], 10);
    var month = parseInt(dateParts[1], 10) - 1;
    var year = parseInt(dateParts[2], 10);
    var hour = parseInt(timeParts[0], 10);
    var minute = parseInt(timeParts[1], 10);
    
    return new Date(year, month, day, hour, minute);
  } catch (e) {
    return new Date(str);
  }
}

function isSameDay(d1, d2) {
  return d1.getFullYear() === d2.getFullYear() &&
         d1.getMonth() === d2.getMonth() &&
         d1.getDate() === d2.getDate();
}

function getStartOfWeek(date) {
  var d = new Date(date);
  var day = d.getDay();
  var diff = d.getDate() - day + (day == 0 ? -6 : 1);
  var start = new Date(d.setDate(diff));
  start.setHours(0, 0, 0, 0);
  return start;
}

function getIndonesianDayName(dayIndex) {
  var days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  return days[dayIndex];
}