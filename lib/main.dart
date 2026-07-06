import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart'; // Import this for initLocalStorage
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart'; // We will build this in Step 8

Future<void> main() async {
  // Ensure framework services are ready for native bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the global local storage engine
  await initLocalStorage();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: const ExpenseManagerApp(),
    ),
  );
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 227, 72, 25), // Modernized M3 theme setup
      ),
      home: const HomeScreen(),
    );
  }
}
