import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes/app_pages.dart';
import 'constants/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Pastikan ini tetap ada

void main() async {
  // Initialize locale data untuk Bahasa Indonesia
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HayCrew App',
      debugShowCheckedModeBanner: false,
      
      // --- TAMBAHKAN KONFIGURASI LOKALISASI DI SINI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // English (Backup)
      ],
      locale: const Locale('id', 'ID'), // Memaksa aplikasi menggunakan format Indonesia
      // -----------------------------------------------

      // Theme Configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        
        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      
      // Routes Configuration dengan GetX
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      
      // Default Transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}