import 'package:flutter/material.dart';
import 'package:perwira_mobile/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/upload_invoice_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/invoice_history_screen.dart';
import 'screens/profile_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Perwira Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            primary: Color(0xFFC62828), // Merah utama (brand)
            onPrimary: Color(0xFFFFFFFF),
            secondary: Color(0xFF8E0000), // Merah tua
            onSecondary: Color(0xFFFFFFFF),
            tertiary: Color(0xFFEF5350), // Merah terang / accent

            background: Color(0xFFF9FAFB), // Abu muda (background lembut)
            onBackground: Color(0xFF1F2937), // Abu gelap untuk teks utama
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF1F2937),

            surfaceVariant: Color(0xFFE5E7EB), // Abu netral untuk card
            onSurfaceVariant: Color(0xFF4B5563),

            primaryContainer: Color(0xFFFFE5E5), // Aksen lembut merah muda
            onPrimaryContainer: Color(0xFF8E0000),

            error: Color(0xFFDC2626),
            onError: Color(0xFFFFFFFF),

            outline: Color(0xFFD1D5DB),
            outlineVariant: Color(0xFF9CA3AF),
            shadow: Color(0xFF000000),
            brightness: Brightness.light,
          ),

          fontFamily: 'Montserrat',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFC62828),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ),
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const MainScreen(),
          '/upload_invoice': (context) => const UploadInvoiceScreen(),
          '/rewards': (context) => const RewardsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/invoice_history': (context) => const InvoiceHistoryScreen(),
        },
      ),
    );
  }
}
