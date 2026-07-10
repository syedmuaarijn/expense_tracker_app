
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'providers/expense_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: const Trackly(),
    ),
  );
}

class Trackly extends StatelessWidget {
  const Trackly({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return MaterialApp(
      title: 'Trackly',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Light Mode Plum & Lilac theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F4FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4C1D6F),
          secondary: Color(0xFFE36F47),
          surface: Colors.white,
          onSurface: Color(0xFF23102C),
          primaryContainer: Color(0xFFEADCF5),
          onPrimaryContainer: Color(0xFF4C1D6F),
        ),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF4C1D6F).withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      // Dark Mode Velvet Plum Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B0B24),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD3B0E8),
          secondary: Color(0xFFE36F47),
          surface: Color(0xFF2A1637),
          onSurface: Colors.white,
          primaryContainer: Color(0xFF381F4A),
          onPrimaryContainer: Color(0xFFF0E5FA),
        ),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A1637),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}