// Full controller based on your code.
// NOTE: Replace the import below with the correct path if needed.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/services/dbService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:haycrew_app/components/CSuccessSplash.dart';

class LaporanController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';
  static const String baseUrl = 'http://103.253.212.178';

  final _db = DBHelper();

  final jumlahAyamAwalController = TextEditingController();
  final jumlahAyamMatiController = TextEditingController();
  final umurAyamController = TextEditingController();
  final rataBobotController = TextEditingController();
  final catatanController = TextEditingController();

  final dateRange = Rxn<DateTimeRange>();
  final formattedDateRange = 'Pilih Tanggal'.obs;
  final Rx<File?> image = Rx<File?>(null);
  final isLoading = false.obs;
  final laporanList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() { super.onInit(); fetchLaporan(); }

  void selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id','ID'),
    );
    if (picked != null){
      dateRange.value= picked;
      formattedDateRange.value="${DateFormat('dd MMM yyyy','id_ID').format(picked.start)} — ${DateFormat('dd MMM yyyy','id_ID').format(picked.end)}";
    }
  }

  void pickImage() async {
    final picked=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:80);
    if(picked!=null){ image.value=File(picked.path);}
  }

  bool _validate(){
    if(jumlahAyamAwalController.text.isEmpty||
      jumlahAyamMatiController.text.isEmpty||
      umurAyamController.text.isEmpty||
      rataBobotController.text.isEmpty||
      dateRange.value==null){
      Get.snackbar('Error','Mohon lengkapi semua field wajib (*)',backgroundColor: Colors.red.shade100);
      return false;
    }
    final awal=int.parse(jumlahAyamAwalController.text);
    final mati=int.parse(jumlahAyamMatiController.text);
    if(mati>awal){
      Get.snackbar('Periksa Data','Jumlah ayam mati lebih besar dari jumlah ayam awal. Mohon cek kembali.',backgroundColor: Colors.orange.shade100);
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if(!_validate()) return;
    isLoading.value=true;
    final now=DateTime.now().toIso8601String();
    final localData={
      'jumlah_ayam_awal':int.parse(jumlahAyamAwalController.text),
      'jumlah_ayam_mati':int.parse(jumlahAyamMatiController.text),
      'umur_ayam':int.parse(umurAyamController.text),
      'rata_rata_bobot':double.parse(rataBobotController.text),
      'catatan':catatanController.text,
      'foto':image.value?.path,
      'tanggal_mulai':DateFormat('yyyy-MM-dd').format(dateRange.value!.start),
      'tanggal_selesai':DateFormat('yyyy-MM-dd').format(dateRange.value!.end),
      'is_synced':0,
      'created_at':now,
    };
    try{
      final id=await _db.addLaporan(localData);
      final success=await _submitToApi(localData);
      if(success){
        await _db.markAsSynced(id);
        _resetForm();
        await fetchLaporan();
        await CSuccessSplash.show(
  message: 'Laporan berhasil\ntersimpan',
);

Future.delayed(const Duration(milliseconds: 200), () {
  Get.offAllNamed(AppRoutes.DASHBOARD_KANDANG);
});
      }
      Get.snackbar('Tersimpan Lokal','Laporan disimpan lokal, akan disync saat online.',backgroundColor: Colors.orange.shade100);
      _resetForm();
      await fetchLaporan();
    }finally{ isLoading.value=false; }
  }

  Future<bool> _submitToApi(Map<String,dynamic> data) async {
    try{
      final req=http.MultipartRequest('POST',Uri.parse('$baseUrl/api/laporan-kandang'));
      req.headers.addAll({'Accept':'application/json','Authorization':'Bearer $_token'});
      data.forEach((k,v){
        if(['foto','is_synced','created_at'].contains(k)) return;
        if(v!=null) req.fields[k]=v.toString();
      });
      if(data['foto']!=null){
        final f=File(data['foto']);
        if(await f.exists()){
          req.files.add(await http.MultipartFile.fromPath('foto',f.path,filename:path.basename(f.path)));
        }
      }
      final res=await req.send().timeout(const Duration(seconds:30));
      return res.statusCode==200||res.statusCode==201;
    }catch(_){return false;}
  }

  Future<void> fetchLaporan() async=>laporanList.assignAll(await _db.getAllLaporan());
  Future<void> deleteLaporan(int id) async{await _db.deleteLaporan(id);await fetchLaporan();Get.snackbar('Berhasil','Laporan dihapus.');}
  void _resetForm(){jumlahAyamAwalController.clear();jumlahAyamMatiController.clear();umurAyamController.clear();rataBobotController.clear();catatanController.clear();image.value=null;dateRange.value=null;formattedDateRange.value='Pilih Tanggal';}
  @override
  void onClose(){jumlahAyamAwalController.dispose();jumlahAyamMatiController.dispose();umurAyamController.dispose();rataBobotController.dispose();catatanController.dispose();super.onClose();}
}






















// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:haycrew_app/services/dbService.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;

// class LaporanController extends GetxController {
//   final _storage = GetStorage();
//   String get _token => _storage.read('token') ?? '';
//   static const String baseUrl = 'http://103.253.212.178';

//   final _db = DBHelper();

//   final jumlahAyamAwalController = TextEditingController();
//   final jumlahAyamMatiController = TextEditingController();
//   final umurAyamController = TextEditingController();
//   final rataBobotController = TextEditingController();
//   final catatanController = TextEditingController();

//   final dateRange = Rxn<DateTimeRange>();
//   final formattedDateRange = 'Pilih Tanggal'.obs;

//   final Rx<File?> image = Rx<File?>(null);

//   final isLoading = false.obs;
//   final laporanList = <Map<String, dynamic>>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchLaporan();
//   }

//   void selectDateRange() async {
//     final picked = await showDateRangePicker(
//       context: Get.context!,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       locale: const Locale('id', 'ID'),
//     );
//     if (picked != null) {
//       dateRange.value = picked;
//       final String formatted =
//           "${DateFormat('dd MMM yyyy', 'id_ID').format(picked.start)} — ${DateFormat('dd MMM yyyy', 'id_ID').format(picked.end)}";
//       formattedDateRange.value = formatted;
//     }
//   }

//   void pickImage() async {
//     final picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (picked != null) {
//       image.value = File(picked.path);
//     }
//   }

//   bool _validate() {
//     if (jumlahAyamAwalController.text.isEmpty ||
//         jumlahAyamMatiController.text.isEmpty ||
//         umurAyamController.text.isEmpty ||
//         rataBobotController.text.isEmpty ||
//         dateRange.value == null) {
//       Get.snackbar(
//         'Error',
//         'Mohon lengkapi semua field wajib (*).',
//         backgroundColor: Colors.red.shade100,
//       );
//       return false;
//     }
//     return true;
//   }

//   Future<void> submit() async {
//     if (!_validate()) return;

//     isLoading.value = true;

//     final now = DateTime.now().toIso8601String();
//     final localData = {
//       'jumlah_ayam_awal': int.parse(jumlahAyamAwalController.text),
//       'jumlah_ayam_mati': int.parse(jumlahAyamMatiController.text),
//       'umur_ayam': int.parse(umurAyamController.text),
//       'rata_rata_bobot': double.parse(rataBobotController.text),
//       'catatan': catatanController.text,
//       'foto': image.value?.path,
//       'tanggal_mulai': DateFormat('yyyy-MM-dd').format(dateRange.value!.start),
//       'tanggal_selesai': DateFormat('yyyy-MM-dd').format(dateRange.value!.end),
//       'is_synced': 0,
//       'created_at': now,
//     };

//     try {
//       final localId = await _db.addLaporan(localData);

//       final success = await _submitToApi(localData);

//       if (success) {
//         await _db.markAsSynced(localId);
//         Get.snackbar(
//           'Berhasil',
//           'Laporan berhasil disimpan dan dikirim.',
//           backgroundColor: Colors.green.shade100,
//         );
//       } else {
//         Get.snackbar(
//           'Tersimpan Lokal',
//           'Laporan disimpan lokal, akan disync saat online.',
//           backgroundColor: Colors.orange.shade100,
//         );
//       }

//       _resetForm();
//       fetchLaporan();
//     } catch (e) {
//       Get.snackbar('Error', 'Terjadi kesalahan: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> _submitToApi(Map<String, dynamic> data) async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/laporan-kandang');
//       debugPrint('Hitting URL: $uri');
//       final request = http.MultipartRequest('POST', uri);

//       request.headers.addAll({
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $_token',
//       });

//       request.fields['jumlah_ayam_awal'] = data['jumlah_ayam_awal'].toString();
//       request.fields['jumlah_ayam_mati'] = data['jumlah_ayam_mati'].toString();
//       request.fields['umur_ayam'] = data['umur_ayam'].toString();
//       request.fields['rata_rata_bobot'] = data['rata_rata_bobot'].toString();
//       request.fields['tanggal_mulai'] = data['tanggal_mulai'];
//       request.fields['tanggal_selesai'] = data['tanggal_selesai'];
//       if (data['catatan'] != null && data['catatan'].toString().isNotEmpty) {
//         request.fields['catatan'] = data['catatan'];
//       }

//       if (data['foto'] != null && data['foto'].toString().isNotEmpty) {
//         final file = File(data['foto']);
//         if (await file.exists()) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'foto',
//               file.path,
//               filename: path.basename(file.path),
//             ),
//           );
//         }
//       }

//       final streamedResponse = await request.send().timeout(
//         const Duration(seconds: 30),
//       );
//       final statusCode = streamedResponse.statusCode;

//       return statusCode == 200 || statusCode == 201;
//     } catch (e) {
//       debugPrint('API Error: $e');
//       return false;
//     }
//   }

//   Future<void> fetchLaporan() async {
//     final data = await _db.getAllLaporan();
//     laporanList.assignAll(data);
//   }

//   Future<void> deleteLaporan(int id) async {
//     await _db.deleteLaporan(id);
//     fetchLaporan();
//     Get.snackbar('Berhasil', 'Laporan dihapus.');
//   }

//   void _resetForm() {
//     jumlahAyamAwalController.clear();
//     jumlahAyamMatiController.clear();
//     umurAyamController.clear();
//     rataBobotController.clear();
//     catatanController.clear();
//     image.value = null;
//     dateRange.value = null;
//     formattedDateRange.value = 'Pilih Tanggal';
//   }

//   @override
//   void onClose() {
//     jumlahAyamAwalController.dispose();
//     jumlahAyamMatiController.dispose();
//     umurAyamController.dispose();
//     rataBobotController.dispose();
//     catatanController.dispose();
//     super.onClose();
//   }
// }
