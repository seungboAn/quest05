import 'package:flutter/material.dart';
import 'package:jellyfish_classifier/routes/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jellyfish Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEEEEEE),
      ),
      initialRoute: AppRouter.home,
      routes: AppRouter.routes,
    );
  }
}
