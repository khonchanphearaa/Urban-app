import 'package:flutter/material.dart';
// import 'common/theme/app_colors.dart';
import 'features/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      
      // Apply your global design theme
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        // Use GoogleFonts if you added it to pubspec
        fontFamily: 'Montserrat', 
      ),
      
      // The first screen the user sees
      home: const HomePage(),
      
      // Optional: Define named routes for better organization
      // routes: {
      //   '/home': (context) => const HomePage(),
      //   '/cart': (context) => const CartPage(),
      // },
    );
  }
}