import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before any async code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Setup Environment Variables or Firebase (Optional)
  // await Firebase.initializeApp();

  // 3. ProviderScope is required for Riverpod to work
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}