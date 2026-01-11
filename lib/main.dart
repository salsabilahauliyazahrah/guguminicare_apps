import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:tugas_akhir/core/theme/app_theme.dart';
import 'package:tugas_akhir/presentation/navigation/app_router.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart'; // TAMBAHKAN IMPORT

void main() async {
  // 1. Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize StorageHelper SEBELUM runApp
  print('🚀 Initializing StorageHelper...');
  try {
    await StorageHelper.init();
    print('✅ StorageHelper initialized successfully');
  } catch (e) {
    print('❌ ERROR initializing StorageHelper: $e');
    // Jangan throw, biarkan app tetap jalan dengan fallback
  }
  
  // 3. Run app dengan DevicePreview
  runApp(
    DevicePreview(
      enabled: true, // Set false untuk production
      builder: (context) => ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget { // UBAH ke ConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PetCare',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // PENTING untuk DevicePreview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}