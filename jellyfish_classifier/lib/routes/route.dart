import 'package:flutter/material.dart';
import 'package:jellyfish_classifier/screens/home_screen.dart';
import 'package:jellyfish_classifier/screens/upload_screen.dart';

class AppRouter {
  static const String home = '/home';
  static const String upload = '/upload';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => HomeScreen(),
        upload: (context) => UploadScreen(),
      };
}
